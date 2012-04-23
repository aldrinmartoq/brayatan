//
//  Response.m
//  brayatan
//
//  Created by Aldrin Martoq on 3/21/12.
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

#import "Response.h"

void on_after_write(uv_write_t* req, int status) {
    free(req);
}

void dowrite(client_t *client, NSString *string) {
    uv_write_t *write_req = malloc(sizeof(uv_write_t));
    uv_buf_t write_buf;
    write_buf.len = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    write_buf.base = (char *)[string cStringUsingEncoding:NSUTF8StringEncoding];
    uv_write(write_req, (uv_stream_t*)&client->handle, &write_buf, 1, on_after_write);
}

static NSString *statusCode(int status) {
    switch(status) {
        case 100: return @"Continue";
        case 101: return @"Switching Protocols";
        case 200: return @"OK";
        case 201: return @"Created";
        case 202: return @"Accepted";
        case 203: return @"Non-Authoritative Information";
        case 204: return @"No Content";
        case 205: return @"Reset Content";
        case 206: return @"Partial Content";
        case 300: return @"Multiple Choices";
        case 301: return @"Moved Permanently";
        case 302: return @"Found";
        case 303: return @"See Other";
        case 304: return @"Not Modified";
        case 305: return @"Use Proxy";
        case 307: return @"Temporary Redirect";
        case 400: return @"Bad Request";
        case 401: return @"Unauthorized";
        case 402: return @"Payment Required";
        case 403: return @"Forbidden";
        case 404: return @"Not Found";
        case 405: return @"Method Not Allowed";
        case 406: return @"Not Acceptable";
        case 407: return @"Proxy Authentication Required";
        case 408: return @"Request Timeout";
        case 409: return @"Conflict";
        case 410: return @"Gone";
        case 411: return @"Length Required";
        case 412: return @"Precondition Failed";
        case 413: return @"Request Entity Too Large";
        case 414: return @"Request-URI Too Long";
        case 415: return @"Unsupported Media Type";
        case 416: return @"Requested Range Not Satisfiable";
        case 417: return @"Expectation Failed";
        case 500: return @"Internal Server Error";
        case 501: return @"Not Implemented";
        case 502: return @"Bad Gateway";
        case 503: return @"Service Unavailable";
        case 504: return @"Gateway Timeout";
        case 505: return @"HTTP Version Not Supported";
    }
    return [NSString stringWithFormat:@"Unknown status %d", status];
}

@implementation Response

@synthesize headers;
@synthesize status;

- (id) initWithClient:(client_t*)c {
    if (self = [super init]) {
        headers = [[NSMutableDictionary alloc] init];
        client = c;
        status = 200;
        [headers setObject:@"Brayatan" forKey:@"Server"];
    }
    return self;
}

- (Response *)setHeader:(NSString *)header value:(NSString *)value {
    [headers setObject:value forKey:header];
    
    return self;
}


- (BOOL)endWithBody:(NSString *)body {
    NSMutableString *tmp = [[NSMutableString alloc] init];

    [tmp appendFormat:@"HTTP/1.1 %d %@\r\n", status, statusCode(status)];
    for (id key in headers) {
        [tmp appendFormat:@"%@: %@\r\n", key, [headers objectForKey:key]];
    }
    [tmp appendFormat:@"\r\n"];
    [tmp appendFormat:body];
    dowrite(client, tmp);

    uv_close((uv_handle_t*)&client->handle, on_close);
    return YES;
}

@end

