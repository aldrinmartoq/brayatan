//
//  brayatan-common.h
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

#ifndef brayatan_common_h
#define brayatan_common_h

#import "brayatan-core.h"
#import "http_parser.h"

#define BRAYATAN_VERSION "0.0.1"

#define BR_BUILD_VERSION_NSSTR @"Brayatan/" BRAYATAN_VERSION " (Build " __TIME__ " " __DATE__ ")"

typedef struct {
    br_client_t *clnt;
    http_parser parser;
    void *http;
    void *request;
    void *response;
    BOOL was_header_field;
    BOOL was_header_value;
    void *last_header_field;
} client_t;



#endif
