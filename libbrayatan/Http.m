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
#import "Request.h"
#import "Response.h"
#import "brayatan-core.h"

static br_loop_t *loop;

int on_header_field(http_parser* parser, const char *at, size_t length) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        
        void *last = client->last_header_field;
        if (client->was_header_field) { // append field
            client->last_header_field = (__bridge_retained void *)[NSString stringWithFormat:@"%@%.*s", last, length, at];
        } else { // create field
            client->last_header_field = (__bridge_retained void *)[NSString stringWithFormat:@"%.*s", length, at];
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
        Request *request = (__bridge Request *)client->request;
        
        if (client->was_header_value) { // append value
            NSString *field = (__bridge NSString *)client->last_header_field;
            NSString *value = [request.headers objectForKey:field];
            [request.headers setObject:[NSString stringWithFormat:@"%@%.*s", value, length, at] forKey:field];
        } else { // create value
            NSString *field = (__bridge NSString *)client->last_header_field;
            [request.headers setObject:[NSString stringWithFormat:@"%.*s", length, at] forKey:field];
        }
        
        client->was_header_field = NO;
        return 0;
    }
}

int on_headers_complete(http_parser* parser) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        Request *request = (__bridge Request *)client->request;
        
        request.host = [[request headers] objectForKey:@"Host"];
        return 0;
    };
}

int on_message_complete(http_parser *parser) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        Response *response = client->response != NULL ? (__bridge Response *)client->response : nil;
        Request *request = client->request != NULL ? (__bridge Request *)client->request : nil;
        Http *http = (__bridge Http *)client->http;

        [http invokeReq:request invokeRes:response];
        return 0;
    }
}

int on_url (http_parser* parser, const char *at, size_t length) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        Request *request = (__bridge Request *)client->request;
        
        request.urlPath = (request.urlPath == nil ? [NSString stringWithFormat:@"%.*s", length, at] : [NSString stringWithFormat:@"%@%.*s", request.urlPath, length, at]);
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

- (BOOL) listenWithIP:(NSString *)ip atPort:(NSString *)port callback:(void (^)(Request *req, Response *res))cb {
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
            client->request =  (__bridge_retained void *)[[Request alloc] init];
            client->response = (__bridge_retained void *)[[Response alloc] initWithClient:client];
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

- (void) invokeReq:(Request *)req invokeRes:(Response *)res {
    callback(req, res);
}


+ (Http *) createServerWithIP:(NSString *)ip atPort:(NSString *)port callback:(void (^)(Request *req, Response *res))callback {
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
    return [NSString stringWithFormat:@"<Http: 0x%lx ip: %@ port: %@ url: http://%@:%@/ >", self, _ip, _port, _ip, _port];
}

+ (void) initialize {
    loop = br_loop_create();
}

+ (void) runloop {
    br_runloop(loop);
}

@end
