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
#import "brayatan-core.h"
#import <sys/resource.h>
#import <sys/time.h>

static br_loop_t *loop;

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
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        
        void *last = client->last_header_field;
        if (client->was_header_field) { // append field
            client->last_header_field = (__bridge_retained void *)[NSString stringWithFormat:@"%@%.*s", last, (int)length, at];
        } else { // create field
            client->last_header_field = (__bridge_retained void *)[NSString stringWithFormat:@"%.*s", (int)length, at];
            client->was_header_field = YES;
        }
        
        if (last != NULL) CFRelease(last);
        
        client->was_header_value = NO;
        return 0;
    }
}

int on_header_value(http_parser* parser, const char *at, size_t length) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        HttpRequest *request = (__bridge HttpRequest *)client->request;
        
        if (client->was_header_value) { // append value
            NSString *field = (__bridge NSString *)client->last_header_field;
            NSString *value = [request.headers objectForKey:field];
            [request.headers setObject:[NSString stringWithFormat:@"%@%.*s", value, (int)length, at] forKey:field];
        } else { // create value
            NSString *field = (__bridge NSString *)client->last_header_field;
            [request.headers setObject:[NSString stringWithFormat:@"%.*s", (int)length, at] forKey:field];
        }
        
        client->was_header_field = NO;
        return 0;
    }
}

int on_headers_complete(http_parser* parser) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        HttpRequest *request = (__bridge HttpRequest *)client->request;
        
        request.host = [[request headers] objectForKey:@"Host"];
        return 0;
    };
}

int on_message_complete(http_parser *parser) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        HttpResponse *response = client->response != NULL ? (__bridge HttpResponse *)client->response : nil;
        HttpRequest *request = client->request != NULL ? (__bridge HttpRequest *)client->request : nil;
        Http *http = (__bridge Http *)client->http;

        [http invokeReq:request invokeRes:response];
        return 0;
    }
}

int on_url (http_parser* parser, const char *at, size_t length) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        HttpRequest *request = (__bridge HttpRequest *)client->request;
        
        request.urlPath = (request.urlPath == nil ? [NSString stringWithFormat:@"%.*s", (int)length, at] : [NSString stringWithFormat:@"%@%.*s", request.urlPath, (int)length, at]);
        return 0;
    }
}


@implementation Http

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

    br_server_t *serv = br_server_create(loop, (char *)[ip UTF8String], (char *)[port UTF8String], ^(br_client_t *clnt) {
        @autoreleasepool {
            /* on_accept */
            br_log_debug("HTTP ACCEPT socket %d %s:%s", clnt->sock.fd, clnt->sock.hbuf, clnt->sock.sbuf);
            
            client_t *client = &_clients[clnt->sock.fd];
            http_parser *parser = &(client->parser);
            http_parser_init(parser, HTTP_REQUEST);
            parser->data = client;
            client->clnt = clnt;
            client->http = (__bridge void *)self;
            client->request =  (__bridge_retained void *)[[HttpRequest alloc] init];
            client->response = (__bridge_retained void *)[[HttpResponse alloc] initWithClient:client];
            client->was_header_field = NO;
            client->was_header_value = NO;
            client->last_header_field = nil;
            
            br_socket_addwatch((br_socket_t *)clnt, BRSOCKET_WATCH_READ);
        };
    }, ^(br_client_t *clnt, char *buff, size_t buff_len) {
        @autoreleasepool {
            /* on_read */
            br_log_debug("HTTP READ   socket %d %s:%s", clnt->sock.fd, clnt->sock.hbuf, clnt->sock.sbuf);
            
            client_t *client = &_clients[clnt->sock.fd];
            http_parser *parser = &(client->parser);
            http_parser_execute(parser, &_settings, buff, buff_len);
        };
    }, ^(br_client_t *clnt) {
        @autoreleasepool {
            /* on_close */
            br_log_debug("HTTP CLOSE  socket %d %s:%s", clnt->sock.fd, clnt->sock.hbuf, clnt->sock.sbuf);
            
            client_t *client = &_clients[clnt->sock.fd];
            if (client->last_header_field != nil) CFRelease(client->last_header_field);
            if (client->request != nil) CFRelease(client->request);
            if (client->request != nil) CFRelease(client->response);
        }
    }, ^(br_server_t *serv) {
        /* on_release */
        br_log_debug("HTTP RELEASE SERVER %d %s:%s", serv->sock.fd, serv->sock.hbuf, serv->sock.sbuf);
    });

    if (serv == NULL) {
        return NO;
    }

    return YES;
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
    NSLog(@"dealloc: %@", self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Http: 0x%llx ip: %@ port: %@ url: http://%@:%@/ >", (unsigned long long)self, _ip, _port, _ip, _port];
}

+ (void) initialize {
    loop = br_loop_create();
}

+ (void) runloop {
    gettimeofday(&time_start, NULL);
    br_runloop(loop);
}

@end
