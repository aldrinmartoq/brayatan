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

#import "HttpResponse.h"
#import <dirent.h>
#import "GRMustache.h"
#import <sys/stat.h>

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
    if ([path hasSuffix:@".svg"]) return @"image/svg+xml";

    if ([path hasSuffix:@".ico"]) return @"image/x-icon";
    return @"text/plain";
}

@implementation HttpResponse

@synthesize headers;
@synthesize status;

- (id) initWithClient:(BRClient *)client {
    if (self = [super init]) {
        headers = [[NSMutableDictionary alloc] init];
        self.client = client;
        status = 200;
        [headers setObject:BR_BUILD_VERSION_NSSTR forKey:@"Server"];
        [headers setObject:br_time_fmt_gmt_now() forKey:@"Date"];
    }
    return self;
}

- (HttpResponse *)setHeader:(NSString *)header value:(NSString *)value {
    [headers setObject:value forKey:header];
    
    return self;
}


- (void)writeHeader {
    NSMutableString *buff = [NSMutableString stringWithFormat:@"HTTP/1.1 %d %s\r\n", status, statusCodeChar(status)];

    for (id key in headers) {
        [buff appendFormat:@"%@: %@\r\n", key, [headers objectForKey:key]];
    }
    [buff appendString:@"\r\n"];
    [self.client write_string:buff];
}

- (void)appendStringToBodyBuffer:(NSString *)string {
    BRTraceLog(@"%@ %@", self, self.client);
    bodyBuffer = bodyBuffer == nil ? [[NSMutableString alloc] init] : bodyBuffer;
    [bodyBuffer appendString:string];
}

- (void)appendFormatToBodyBuffer:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [self appendStringToBodyBuffer:[[NSString alloc] initWithFormat:format arguments:args]];
    va_end(args);
}

- (void)send {
    if (bodyBuffer != nil) {
        [self setHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", [bodyBuffer length]]];
    }
    [self writeHeader];
    if (bodyBuffer != nil) {
        [self.client write_string:bodyBuffer];
    }
    [self.client write_close];
}

- (void)writeDirectoryListingFor:(NSString *)fullpath Path:(NSString *)path{
    [self setHeader:@"Content-Type" value:@"text/html; charset=utf-8"];
    [self appendStringToBodyBuffer:[NSString stringWithFormat:@"<HMTL><BODY><H1>Directory Listing for %@</H1>", path]];
    
    struct dirent *e;
    DIR *dir = opendir([fullpath UTF8String]);
    while ((e = readdir(dir)) != NULL) {
        if (e->d_name[0] == '.') continue;
        char *s = e->d_type == DT_DIR ? "/" : "";
        [self appendStringToBodyBuffer:[NSString stringWithFormat:@"<A href=\"%s%s\"/>%s%s</A><BR>", e->d_name, s, e->d_name, s]];
    }
    closedir(dir);
    
    [self appendStringToBodyBuffer:[NSString stringWithFormat:@"<BR><HR><I>%@</I>", BR_BUILD_VERSION_NSSTR]];
    [self send];
}

- (BOOL)dynamicContentForTemplate:(NSString *)name Data:(id)object TemplateRepository:(GRMustacheTemplateRepository *)repository {
    GRMustacheTemplate *template = [repository templateNamed:name error:nil];
    NSString *data = [template renderObject:object error:nil];
    
    [self setHeader:@"Content-Type" value:@"text/html"];
    [self setHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", [data lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]];
    [self writeHeader];

    [self.client write_string:data];
    [self.client write_close];
    
    return YES;
}

- (BOOL)dynamicContentForRequest:(HttpRequest *)req Data:(id)object TemplateFolder:(NSString *)folder {
    NSRange range = [req.urlPath rangeOfString:@"/../"];
    if (range.location != NSNotFound) {
        self.status = 400;
        [self setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
        [self appendStringToBodyBuffer:@"/../ is not allowed in path\r\n"];
        [self send];
        return YES;
    }
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:folder];
    GRMustacheTemplate *template = [repository templateNamed:req.urlPath error:nil];
    
    NSString *data = [template renderObject:object error:nil];
    
    [self setHeader:@"Content-Type" value:@"text/html"];
    [self setHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", [data lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]];
    [self writeHeader];
    
    [self.client write_string:data];
    [self.client write_close];
    
    return YES;
}

- (BOOL)staticContentForRequest:(HttpRequest *)req FromFolder:(NSString *)folder {
    NSRange range = [req.urlPath rangeOfString:@"/../"];
    if (range.location != NSNotFound) {
        self.status = 400;
        [self setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
        [self appendStringToBodyBuffer:@"/../ is not allowed in path\r\n"];
        [self send];
        return YES;
    }

    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", folder, req.urlPath];
    
    __block NSString *indexFile = nil;
    [self.client write_file:fullPath onOpen:^BOOL(struct stat stat) {
        if (S_ISDIR(stat.st_mode)) {
            
            if (![fullPath hasSuffix:@"/"]) {
                [self redirectToURL:[req.urlPath stringByAppendingString:@"/"]];
                return NO;
            }
            
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
                return NO;
            }
            
            [self writeDirectoryListingFor:fullPath Path:req.urlPath];
            [self.client write_close];
            return NO;
        }

        /* HTTP Last-Modified support */
#ifdef __APPLE__
        NSString *lastmod = br_time_fmt_gmt(stat.st_mtimespec.tv_sec);
#else
        NSString *lastmod = br_time_fmt_gmt(stat.st_mtime);
#endif

        if ([lastmod isEqual:[req.headers objectForKey:@"If-Modified-Since"]]) {
            self.status = 304;
        }

        [self setHeader:@"Content-Type" value:contentType(req.urlPath)];
        [self setHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", (long)stat.st_size]];
        [self setHeader:@"Last-Modified" value:lastmod];
        [self writeHeader];

        if (self.status == 304) {
            [self.client write_close];
            return NO;
        }

        return YES;
    } onError:^(int err) {
        /* on_open_error */
        self.status = 404;
        [self setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
        [self appendStringToBodyBuffer:[NSString stringWithFormat:@"%@ Not Found.\r\n\r\n-- %@\r\n", req.urlPath, BR_BUILD_VERSION_NSSTR]];
        [self send];
    }];

    if (indexFile != nil) {
        req.urlPath = [req.urlPath stringByAppendingFormat:@"/%@", indexFile];
        [self staticContentForRequest:req FromFolder:folder];
        [self.client write_close];
    }
    return YES;
}

- (BOOL)redirectToURL:(NSString *)url {
    self.status = 302;
    [self setHeader:@"Location" value:url];
    [self appendStringToBodyBuffer:[NSString stringWithFormat:@"Redirected to %@", url]];
    [self send];
    return YES;
}


@end

