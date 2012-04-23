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

static http_parser_settings settings;

void do_release(uv_handle_t *handle) {
    client_t *client = (client_t *)handle->data;
    if (client->request != NULL) {
        CFRelease(client->request);
        client->request = NULL;
    }
    if (client->response != NULL) {
        CFRelease(client->response);
        client->response = NULL;
    }
    if (client->last_header_field != NULL) {
        CFRelease(client->last_header_field);
        client->last_header_field = NULL;
    }
}

void on_close(uv_handle_t *handle) {
    do_release(handle);
    client_t *client = (client_t *)handle->data;
    free(client);
}

uv_buf_t on_alloc(uv_handle_t* handle, size_t suggested_size) {
    uv_buf_t buf;
    buf.base = malloc(suggested_size);
    buf.len = suggested_size;
    return buf;
}

void on_read(uv_stream_t* handle, ssize_t nread, uv_buf_t buf) {
    client_t *client = (client_t *)handle->data;
    if (nread >= 0) {
        /* parse http ... somehow */
        size_t parsed = http_parser_execute(&client->parser, &settings, buf.base, nread);
        if (parsed < nread) {
            uv_close((uv_handle_t*)handle, on_close);
        }
    } else {
        uv_err_t err = uv_last_error(uv_default_loop());
        if (err.code == UV_EOF) {
            uv_close((uv_handle_t*)handle, on_close);
        } else {
            /* handle error here */
        }
    }
    free(buf.base);
}

int on_header_field(http_parser* parser, const char *at, size_t length) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        
        void *last = client->last_header_field;
        if (client->was_header_field) { /* append field */
            client->last_header_field = (__bridge_retained void *)[NSString stringWithFormat:@"%@%.*s", last, length, at];
        } else { /* create field */
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
        
        if (client->was_header_value) { /* append value */
            NSString *field = (__bridge NSString *)client->last_header_field;
            NSString *value = [request.headers objectForKey:field];
            [request.headers setObject:[NSString stringWithFormat:@"%@%.*s", value, length, at] forKey:field];
        } else { /* create value */
            NSString *field = (__bridge NSString *)client->last_header_field;
            [request.headers setObject:[NSString stringWithFormat:@"%.*s", length, at] forKey:field];
        }
        
        client->was_header_field = NO;
        return 0;
    }
}

int on_url (http_parser* parser, const char *at, size_t length) {
    @autoreleasepool {
        client_t *client = (client_t *)parser->data;
        Request *request = (__bridge Request *)client->request;
        
        request.url = (request.url == nil ? [NSString stringWithFormat:@"%.*s", length, at] : [NSString stringWithFormat:@"%@%.*s", request.url, length, at]);
        return 0;
    }
}


int on_headers_complete(http_parser* parser) {
//    @autoreleasepool {
//        client_t *client = (client_t *)parser->data;
//        Response *response = client->response != NULL ? (__bridge Response *)client->response : nil;
//        Request *request = client->request != NULL ? (__bridge Request *)client->request : nil;
//        Http *http = (__bridge Http *)client->http;
//        
//        [http invokeReq:request invokeRes:response];
//
//        return 0;
//    }
    return 0;
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

void on_connection(uv_stream_t* uv_tcp, int status) {
        //NSLog(@"connected: %@", uv_tcp->data);
        
        client_t *client = malloc(sizeof(client_t));
        client->request = NULL;
        uv_tcp_init(uv_tcp->loop, &client->handle);
        
        int r = uv_accept(uv_tcp, (uv_stream_t*)&client->handle);
        if (r) {
            //NSLog(@"accept: %s\n", uv_strerror(uv_last_error(uv_default_loop())));
            return;
        }
        
        http_parser_init(&client->parser, HTTP_REQUEST);
        
        client->handle.data = client;
        client->parser.data = client;
        client->http = uv_tcp->data;
        client->request =  (__bridge_retained void *)[[Request alloc] init];
        client->response = (__bridge_retained void *)[[Response alloc] initWithClient:client];
        client->was_header_field = NO;
        client->was_header_value = NO;
        client->last_header_field = NULL;
        
        settings.on_headers_complete = on_headers_complete;
        settings.on_message_complete = on_message_complete;
        settings.on_header_field = on_header_field;
        settings.on_header_value = on_header_value;
        settings.on_url = on_url;
        
        uv_read_start((uv_stream_t*)&client->handle, on_alloc, on_read);
}

@implementation Http

- (id) init {
    if (self = [super init]) {
        uv_tcp = malloc(sizeof(uv_tcp_t));
        uv_tcp_init(uv_default_loop(), uv_tcp);
        uv_tcp->data = (__bridge void *)self;
    }
    
    return self;
}

- (BOOL) listenWithIP:(NSString *)ip atPort:(int)port callback:(void (^)(Request *req, Response *res))cb {
    int r = uv_tcp_bind(uv_tcp, uv_ip4_addr([ip cStringUsingEncoding:NSASCIIStringEncoding], port));
    
    _ip = ip;
    _port = port;
    
    if (r) {
        return NO;
    }
    
    r = uv_listen((uv_stream_t*)uv_tcp, 128, on_connection);
    if (r) {
        return NO;
    }
    
    callback = cb;
        
    return YES;
}

- (void) invokeReq:(Request *)req invokeRes:(Response *)res {
    callback(req, res);
}


+ (Http *) createServerWithIP:(NSString *)ip atPort:(int)port callback:(void (^)(Request *req, Response *res))callback {
    Http *http = [[Http alloc] init];
    if ([http listenWithIP:ip atPort:port callback:callback]) {
        return http;
    }
    return nil;
}

- (void) dealloc {
    free(uv_tcp);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Http: 0x%lx ip:%@ port:%d>", self, _ip, _port];
}
@end
