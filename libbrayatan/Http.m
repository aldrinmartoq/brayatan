//
//  Http.m
//  brayatan
//
//  Created by Aldrin Martoq on 3/18/12.
//  Copyright (c) 2012 A0. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "Http.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "BRServer.h"
#import <sys/resource.h>
#import <sys/time.h>

@interface HttpClient : NSObject {
    http_parser parser;
    NSString *current_header_field;
    NSString *current_header_value;
}

@property (weak) BRClient *client;
@property (weak) Http *http;
@property HttpRequest *request;
@property HttpResponse *response;

@end

@implementation HttpClient

- (id)initWithClient:(BRClient *)client Http:(Http *)http {
    if (self = [super init]) {
        self.client = client;
        self.http = http;
        self.request = [[HttpRequest alloc] init];
        self.response = [[HttpResponse alloc] initWithClient:client];
        http_parser_init(&parser, HTTP_REQUEST);
        parser.data = (__bridge void *)self;
        current_header_field = current_header_value = nil;
    }
    
    return self;
}

- (void)execute_parser:(http_parser_settings *)settings data:(const void *)data len:(size_t)len {
    http_parser_execute(&parser, settings, data, len);
}

- (void)on_header_field_At:(const char *)at length:(size_t)length {
    if (current_header_field != nil && current_header_value == nil) {
        // append to current header field
        current_header_field = [NSString stringWithFormat:@"%@%.*s", current_header_field, (int)length, at];
    } else {
        if (current_header_field != nil) {
            // add field,value to request headers
            [self.request.headers setObject:current_header_value forKey:current_header_field];
        }
        // create header field
        current_header_field = [NSString stringWithFormat:@"%.*s", (int)length, at];
        current_header_value = nil;
    }
}

- (void)on_header_value_At:(const char *)at length:(size_t)length {
    if (current_header_value != nil) {
        // append to current header value
        current_header_value = [NSString stringWithFormat:@"%@%.*s", current_header_value, (int)length, at];
    } else {
        // create header field
        current_header_value = [NSString stringWithFormat:@"%.*s", (int)length, at];
    }
}

- (void)on_headers_complete {
    if (current_header_field != nil && current_header_value != nil) {
        [self.request.headers setObject:current_header_value forKey:current_header_field];
    }
    self.request.host = [[self.request headers] objectForKey:@"Host"];
}

- (void)dealloc {
    BRDebugLog(@"%@ DEALLOC", self);
}

@end

struct timeval diff(struct timeval x, struct timeval y) {
    struct timeval r;
    if (x.tv_usec < y.tv_usec) {
        int s = (y.tv_usec - x.tv_usec) / 1000000 + 1;
        y.tv_usec -= 1000000 * s;
        y.tv_sec += s;
    }
    if (x.tv_usec - y.tv_usec > 1000000) {
        int s = (x.tv_usec - y.tv_usec) / 1000000;
        y.tv_usec += 1000000 * s;
        y.tv_sec -= s;
    }
    r.tv_sec = x.tv_sec - y.tv_sec;
    r.tv_usec = x.tv_usec - y.tv_usec;
    
    return r;
}

static struct timeval time_start;
static unsigned long long request_count = 0;


int on_header_field(http_parser* parser, const char *at, size_t length) {
    HttpClient *http_client = (__bridge HttpClient *)parser->data;
    [http_client on_header_field_At:at length:length];

    return 0;
}

int on_header_value(http_parser* parser, const char *at, size_t length) {
    HttpClient *http_client = (__bridge HttpClient *)parser->data;
    [http_client on_header_value_At:at length:length];

    return 0;
}

int on_headers_complete(http_parser* parser) {
    HttpClient *http_client = (__bridge HttpClient *)parser->data;
    [http_client on_headers_complete];

    return 0;
}

int on_message_complete(http_parser *parser) {
    HttpClient *http_client = (__bridge HttpClient *)parser->data;
    [http_client.http invokeReq:http_client.request invokeRes:http_client.response];

    return 0;
}

int on_url (http_parser* parser, const char *at, size_t length) {
    HttpClient *http_client = (__bridge HttpClient *)parser->data;
    if (http_client.request.urlPath == nil) {
        http_client.request.urlPath = [NSString stringWithFormat:@"%.*s", (int)length, at];
    } else {
        http_client.request.urlPath = [NSString stringWithFormat:@"%@%.*s", http_client.request.urlPath, (int)length, at];
    }

    return 0;
}


@implementation Http {
    void (^callback)(HttpRequest *req, HttpResponse *res);
    NSString *_ip;
    NSString *_port;
    http_parser_settings _settings;
    client_t _clients[8192];
}

- (id) init {
    if (self = [super init]) {
        _settings.on_url = on_url;
        _settings.on_header_field = on_header_field;
        _settings.on_header_value = on_header_value;
        _settings.on_headers_complete = on_headers_complete;
        _settings.on_message_complete = on_message_complete;
        memset(_clients, 0, sizeof(_clients));
    }
    
    return self;
}

- (BOOL) listenWithIP:(NSString *)ip atPort:(NSString *)port callback:(void (^)(HttpRequest *req, HttpResponse *res))cb {
    callback = cb;
    _ip = ip;
    _port = port;

    BRServer *server = [[BRServer alloc] initWithHostname:ip serviceName:port];
    server.on_accept_client = ^void(BRServer *server, BRClient *client) {
        BRDebugLog(@"%@ HTTP ACCEPT %@", self, client);
        HttpClient *http_client = [[HttpClient alloc] initWithClient:client Http:self];
        client.udata = http_client;
    };
    
    server.on_read_client = ^void(BRServer *server, BRClient *client, NSData *data) {
        BRDebugLog(@"%@ HTTP READ %@", self, client);
        HttpClient *http_client = (HttpClient *)client.udata;
        [http_client execute_parser:&_settings data:[data bytes] len:[data length]];
    };
    
    server.on_close_client = ^void(BRServer *server, BRClient *client) {
        BRDebugLog(@"%@ HTTP CLOSE %@", self, client);
    };
    
    server.on_close = ^void(BRServer *server) {
        BRDebugLog(@"%@ CLOSE %@", self, server);
    };
    
    [server start_server];
    return server != nil;
}

- (void) invokeReq:(HttpRequest *)req invokeRes:(HttpResponse *)res {
    request_count++;
    callback(req, res);
}

+ (NSString *) statusString {
    struct rusage ru;
    getrusage(RUSAGE_SELF, &ru);
    unsigned long t1 = ru.ru_utime.tv_sec;
    unsigned long t2 = ru.ru_utime.tv_usec / 10000;
    unsigned long t3 = ru.ru_stime.tv_sec;
    unsigned long t4 = ru.ru_stime.tv_usec / 10000;
    
    struct timeval time_curr;
    gettimeofday(&time_curr, NULL);
    struct timeval r = diff(time_curr, time_start);
    unsigned long r1 = r.tv_sec;
    unsigned long r2 = r.tv_usec / 10000;

    unsigned long rd = (r.tv_sec) / 3600 / 24;
    unsigned long rh = (r.tv_sec - rd * 3600 *24) / 3600;
    unsigned long rm = (r.tv_sec - rd * 3600 *24 - rh * 3600) / 60;
    unsigned long rs = (r.tv_sec - rd * 3600 *24 - rh * 3600 - rm * 60) / 1;
    
#ifdef __APPLE__
    unsigned long m1 = ru.ru_maxrss / 1024;
#else
    unsigned long m1 = ru.ru_maxrss;
#endif    
    return [NSString stringWithFormat:@"Hola, Flaites! This is %@\n\n--- Server status ---\nRequests: %llu\ncpu user: %ld.%02ld\ncpu  sys: %ld.%02ld\n  uptime: %ld.%02lds (%ld %ldh %ldm %lds)\nmem used: %ld KiB\n", BR_BUILD_VERSION_NSSTR, request_count, t1, t2, t3, t4, r1, r2, rd, rh, rm , rs, m1];
}



+ (Http *) createServerWithIP:(NSString *)ip atPort:(NSString *)port callback:(void (^)(HttpRequest *req, HttpResponse *res))callback {
    Http *http = [[Http alloc] init];
    if ([http listenWithIP:ip atPort:port callback:callback]) {
        return http;
    }
    return nil;
}

- (void) dealloc {
    BRDebugLog(@"%@ DEALLOC", self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Http: 0x%llx ip: %@ port: %@ url: http://%@:%@/ >", (unsigned long long)self, _ip, _port, _ip, _port];
}

+ (void) initialize {
    gettimeofday(&time_start, NULL);
}

+ (void) runloop {
    dispatch_main();
}

@end
