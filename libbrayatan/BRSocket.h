//
//  BRSocket.h
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/4/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "brayatan-common.h"

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
- (void)setup_read:(brayatan_read_block)block;
- (void)cancel_read;
- (void)setup_write:(brayatan_write_block)block;
- (void)cancel_write;
- (void)fd_close;

+ (dispatch_queue_t) dispatch_queue;

@end
