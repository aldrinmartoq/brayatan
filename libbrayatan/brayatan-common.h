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

#import "http_parser.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netdb.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#define BRAYATAN_VERSION "0.1.1"

#define BR_BUILD_VERSION_NSSTR @"Brayatan/" BRAYATAN_VERSION " (Build " __TIME__ " " __DATE__ ")"

#define BRAYATAN_LOG_TRACE_ENABLED  0
#define BRAYATAN_LOG_DEBUG_ENABLED  0
#define BRAYATAN_LOG_INFOR_ENABLED  1
#define BRAYATAN_LOG_ERROR_ENABLED  1

#if BRAYATAN_LOG_TRACE_ENABLED
#define BRTraceLog(fmt, ...) NSLog((@"T %60s:%-4d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define BRTraceLog(...)
#endif

#if BRAYATAN_LOG_DEBUG_ENABLED
#define BRDebugLog(fmt, ...) NSLog((@"D %60s:%-4d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define BRDebugLog(...)
#endif

#if BRAYATAN_LOG_INFOR_ENABLED
#define BRInforLog(fmt, ...) NSLog((@"I %60s:%-4d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define BRInforLog(...)
#endif

#if BRAYATAN_LOG_ERROR_ENABLED
#define BRErrorLog(fmt, ...) NSLog((@"E %60s:%-4d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define BRErrorLog(...)
#endif

typedef struct br_loop {
    int qfd;
    unsigned int usage;
    struct br_socket *sockets[1024];
    int sockets_len;
} br_loop_t;

typedef struct br_socket {
    int type;
    unsigned int usage;
    int fd;
    br_loop_t *loop;
//    struct sockaddr in_addr;
    char hbuf[256], sbuf[256];
    int watchmode;
} br_socket_t;

typedef struct br_server {
    br_socket_t sock;
    void *on_accept;
    void *on_read;
    void *on_close;
    void *on_release;
    void *udata;
} br_server_t;

typedef struct br_client {
    br_socket_t sock;
    br_server_t *serv;
    void *on_write;
    void *udata;
    char rbuff[1024*4];
} br_client_t;

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

NSString *br_time_fmt_gmt(time_t t);
NSString *br_time_fmt_gmt_now();

#endif
