//
//  Http.h
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

#import <Foundation/Foundation.h>
#import "Request.h"
#import "Response.h"
#import "brayatan-common.h"

#ifndef __APPLE__
void CFRelease(void *o);
#endif


@interface Http : NSObject {
    void (^callback)(Request *req, Response *res);
    NSString *_ip;
    NSString *_port;
    http_parser_settings _settings;
    client_t _clients[8192];
}

- (void) invokeReq:(Request *)req invokeRes:(Response *)res;
+ (NSString *) statusString;
+ (Http *) createServerWithIP:(NSString *)ip atPort:(NSString *)port callback:(void (^)(Request *req, Response *res))callback;
+ (void) runloop;
@end
