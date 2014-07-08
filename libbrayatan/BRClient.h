//
//  BRClient.h
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/4/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "BRSocket.h"
#import "BRServer.h"

@class BRServer;
@class BRClient;

typedef enum {
    kBrayatanWriteBlockCont,
    kBrayatanWriteBlockNext,
    kBrayatanWriteBlockDone
} brayatan_write_block_result;

typedef brayatan_write_block_result (^BRClientWriteBlock)(BRClient *client, size_t length);
typedef BOOL (^BRClientSendfileOnOpenBlock)(struct stat stat);
typedef void (^BRClientSendfileOnErrorBlock)(int err);

@interface BRClient : BRSocket

@property NSMutableArray *push_write_array;
@property BRServer *server;
@property NSObject *udata;

- (id)initWithFd:(int)fd server:(BRServer *)server addr:(struct sockaddr)in_addr hostname:(NSString *)hostname servname:(NSString *)servname;
- (void)start_client;
- (void)stop_client;
- (void)write_data:(NSData *)data;
- (void)write_string:(NSString *)string;
- (void)write_file:(NSString *)path onOpen:(BRClientSendfileOnOpenBlock)on_open onError:(BRClientSendfileOnErrorBlock)on_error;
- (void)write_close;

@end
