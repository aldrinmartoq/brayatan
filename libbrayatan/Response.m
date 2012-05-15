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
#import <dirent.h>

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

static char *statusCodeChar(int status) {
    switch(status) {
        case 100: return "Continue";
        case 101: return "Switching Protocols";
        case 200: return "OK";
        case 201: return "Created";
        case 202: return "Accepted";
        case 203: return "Non-Authoritative Information";
        case 204: return "No Content";
        case 205: return "Reset Content";
        case 206: return "Partial Content";
        case 300: return "Multiple Choices";
        case 301: return "Moved Permanently";
        case 302: return "Found";
        case 303: return "See Other";
        case 304: return "Not Modified";
        case 305: return "Use Proxy";
        case 307: return "Temporary Redirect";
        case 400: return "Bad Request";
        case 401: return "Unauthorized";
        case 402: return "Payment Required";
        case 403: return "Forbidden";
        case 404: return "Not Found";
        case 405: return "Method Not Allowed";
        case 406: return "Not Acceptable";
        case 407: return "Proxy Authentication Required";
        case 408: return "Request Timeout";
        case 409: return "Conflict";
        case 410: return "Gone";
        case 411: return "Length Required";
        case 412: return "Precondition Failed";
        case 413: return "Request Entity Too Large";
        case 414: return "Request-URI Too Long";
        case 415: return "Unsupported Media Type";
        case 416: return "Requested Range Not Satisfiable";
        case 417: return "Expectation Failed";
        case 500: return "Internal Server Error";
        case 501: return "Not Implemented";
        case 502: return "Bad Gateway";
        case 503: return "Service Unavailable";
        case 504: return "Gateway Timeout";
        case 505: return "HTTP Version Not Supported";
    }
    return "";
}

static NSString *contentType(NSString *path) {
    if ([path hasSuffix:@".html"]) return @"text/html; charset=utf-8";
    if ([path hasSuffix:@".jpg"]) return @"image/jpeg";
    if ([path hasSuffix:@".png"]) return @"image/png";
    if ([path hasSuffix:@".js"]) return @"application/x-javascript";
    if ([path hasSuffix:@".css"]) return @"text/css";
    if ([path hasSuffix:@".xml"]) return @"text/xml";
    if ([path hasSuffix:@".gif"]) return @"image/gif";
    if ([path hasSuffix:@".txt"]) return @"text/plain; charset=utf-8";

    if ([path hasSuffix:@".ico"]) return @"image/x-icon";
    return @"text/plain";
}

@implementation Response

@synthesize headers;
@synthesize status;

- (id) initWithClient:(client_t*)c {
    if (self = [super init]) {
        headers = [[NSMutableDictionary alloc] init];
        client = c;
        status = 200;
        [headers setObject:BRVERSION forKey:@"Server"];
        [headers setObject:[[NSString alloc] initWithCString:br_time_char_gmt() encoding:NSUTF8StringEncoding] forKey:@"Date"];
    }
    return self;
}

- (Response *)setHeader:(NSString *)header value:(NSString *)value {
    [headers setObject:value forKey:header];
    
    return self;
}


- (void)writeHeader {
    @autoreleasepool {
        char buff2[1024*4];
        char *b = buff2;
        
        int n = sprintf(buff2, "HTTP/1.1 %d %s\r\n", status, statusCodeChar(status));
        b += n;
        
        for (id key in headers) {
            n = sprintf(b, "%s: %s\r\n", [key UTF8String], [[headers objectForKey:key] UTF8String]);
            b += n;
        }
        n = sprintf(b, "\r\n");
        size_t buff_len = strlen(buff2);
        br_client_write(client->clnt, buff2, buff_len, ^(br_client_t *c) {
            br_log_error("ERROR on writeHeader %d %s:%s", c->sock.fd, c->sock.hbuf, c->sock.sbuf);
        });
    };
}

- (void)writeBody:(NSString *)body {
    char *buff = (char *)[body UTF8String];
    size_t buff_len = strlen(buff);
    br_client_write(client->clnt, buff, buff_len, ^(br_client_t *c) {
        br_log_error("ERROR on writeHeader %d %s:%s", c->sock.fd, c->sock.hbuf, c->sock.sbuf);
    });
}

- (BOOL)endWithBody:(NSString *)body {
    @autoreleasepool {
        NSMutableString *tmp = [[NSMutableString alloc] init];
        
        br_log_debug("HERE");
        
        [tmp appendFormat:@"HTTP/1.1 %d %@\r\n", status, statusCode(status)];
        for (id key in headers) {
            [tmp appendFormat:@"%@: %@\r\n", key, [headers objectForKey:key]];
        }
        [tmp appendFormat:@"\r\n"];
        [tmp appendFormat:body];
        char *buff = (char *)[tmp UTF8String];
        size_t buff_len = strlen(buff);
        br_client_write(client->clnt, buff, buff_len, ^(br_client_t *c) {
            br_log_error("RESPONSE ERROR on %d %s:%s", c->sock.fd, c->sock.hbuf, c->sock.sbuf);
        });
        
        br_client_close(client->clnt);
        
        return YES;
    };
}

- (void)writeDirectoryListingFor:(NSString *)fullpath Path:(NSString *)path{
    @autoreleasepool {
        [self setHeader:@"Content-Type" value:@"text/html; charset=utf-8"];
        [self writeHeader];
        [self writeBody:[NSString stringWithFormat:@"<HMTL><BODY><H1>Directory Listing for %@</H1>", path]];

        struct dirent *e;
        DIR *dir = opendir([fullpath UTF8String]);
        while ((e = readdir(dir)) != NULL) {
            if (e->d_name[0] == '.') continue;
            [self writeBody:[NSString stringWithFormat:@"<A href=\"%s\"/>%s</A><BR>", e->d_name, e->d_name]];
        }
        closedir(dir);

        [self writeBody:[NSString stringWithFormat:@"<BR><HR><I>%@</I>", BRVERSION]];
    };
}


- (BOOL)staticContentForPath:(NSString *)path FromFolder:(NSString *)folder {
    @autoreleasepool {
        NSRange range = [path rangeOfString:@"/../"];
        if (range.location != NSNotFound) {
            self.status = 400;
            [self setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
            [self endWithBody:@"/../ is not allowed in path\r\n"];
            return YES;
        }

        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", folder, path];
        
        br_client_sendfile(client->clnt, (char *)[fullPath UTF8String], ^BOOL(br_client_t *c, struct stat stat) {
            /* on_open */
            if (S_ISDIR(stat.st_mode)) {
                NSString *indexFile = nil;
                struct dirent *e;
                DIR *dir = opendir([fullPath UTF8String]);
                while ((e = readdir(dir)) != NULL) {
                    if (strncmp(e->d_name, "index.html", 10) == 0) {
                        indexFile = @"index.html";
                        break;
                    }
                }
                closedir(dir);
                
                if (indexFile != nil) {
                    [self staticContentForPath:indexFile FromFolder:fullPath];
                    return NO;
                }

                [self writeDirectoryListingFor:fullPath Path:path];
                return NO;
            }
            
            [self setHeader:@"Content-Type" value:contentType(path)];
            [self setHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", stat.st_size]];
            [self writeHeader];
            br_socket_delwatch((br_socket_t*)c, BRSOCKET_WATCH_READ);

            return YES;
        }, ^(br_client_t *c, int err) {
            /* on_open_error */
            self.status = 404;
            [self setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
            [self endWithBody:[NSString stringWithFormat:@"%@ Not Found.\r\n\r\n-- %@\r\n", path, BRVERSION]];
        });

        br_client_close(client->clnt);
    }
    return YES;
}

@end

