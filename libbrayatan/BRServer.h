//
//  BRServer.h
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/4/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRSocket.h"
#import "BRClient.h"

@class BRServer;
@class BRClient;

typedef void (^BRServerOnAcceptClientBlock)(BRServer *server, BRClient *client);
typedef void (^BRServerOnReadClientBlock)(BRServer *server, BRClient *client, NSData *data);
typedef void (^BRServerOnCloseClientBlock)(BRServer *server, BRClient *client);
typedef void (^BRServerOnCloseBlock)(BRServer *server);

@interface BRServer : BRSocket

@property (copy) BRServerOnAcceptClientBlock on_accept_client;
@property (copy) BRServerOnReadClientBlock on_read_client;
@property (copy) BRServerOnCloseClientBlock on_close_client;
@property (copy) BRServerOnCloseBlock on_close;

- (id)initWithHostname:(NSString *)hostname serviceName:(NSString *)servicename;
- (void)start_server;
- (void)stop_server;
@end
