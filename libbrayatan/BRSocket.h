//
//  BRSocket.h
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/4/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
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

#define BRAYATAN_LOG_TRACE_ENABLED  0
#define BRAYATAN_LOG_DEBUG_ENABLED  1
#define BRAYATAN_LOG_INFOR_ENABLED  0
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

@interface BRSocket : NSObject

@property struct sockaddr     in_addr;
@property int fd;
@property dispatch_source_t dispatch_source_read;
@property dispatch_source_t dispatch_source_write;
@property NSString *hostname;
@property NSString *servname;

- (BOOL)setNonBlock;
- (void)read_start:(void(^)(void))handler;
- (void)read_cancel;
- (void)write_start_Event:(void(^)(void))event_handler Cancel:(void(^)(void))cancel_handler;
- (void)write_cancel;
- (void)fd_close;

+ (dispatch_queue_t) dispatch_queue;

@end
