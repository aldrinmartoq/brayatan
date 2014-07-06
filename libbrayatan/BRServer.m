//
//  BRServer.m
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/4/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "BRServer.h"
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

@implementation BRServer

- (id)initWithHostname:(NSString *)hostname serviceName:(NSString *)servname {
    if (self = [super init]) {
        self.hostname = hostname;
        self.servname = servname;

        BRInforLog(@"Server %@ created", self);
    }
    return self;
}

- (void)start_server {
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    int r;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;        /* IPv4 and IPv6 */
    hints.ai_socktype = SOCK_STREAM;    /* TCP */
    hints.ai_flags = AI_PASSIVE;        /* All interfaces */
    
    r = getaddrinfo([self.hostname UTF8String], [self.servname UTF8String], &hints, &result);
    if (r != 0) {
        perror("getaddrinfo");
        abort();
    }
    
    for (rp = result; rp != NULL; rp = rp->ai_next) {
        self.fd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (self.fd == -1) {
            continue;
        }
        
        int yes = 1;
        r = setsockopt(self.fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
        if (r == -1) {
            perror("setsockopt");
            abort();
        }
        
        r = bind(self.fd, rp->ai_addr, rp->ai_addrlen);
        if (r == 0) {
            /* bind success */
            self.in_addr = *(rp->ai_addr);
            break;
        }
        close(self.fd);
    }
    
    if (rp == NULL) {
        perror("Could not bind");
        abort();
    }
    
    freeaddrinfo(result);
    
    if (![self setNonBlock]) {
        perror("non blocking IO");
        abort();
    }
    
    r = listen(self.fd, SOMAXCONN);
    if (r == -1) {
        perror("listen");
        abort();
    }
    
    [self read_start:^{
        [self accept_client];
    }];
}

- (void)stop_server {
    [self read_cancel];
    [self fd_close];
}

- (void)accept_client {
    while (true) {
        char hbuf[NI_MAXHOST];
        char sbuf[NI_MAXSERV];
        struct sockaddr in_addr;
        socklen_t in_len = sizeof(struct sockaddr);
        
        int fd = accept(self.fd, &in_addr, &in_len);
        if (fd == -1) {
            if ((errno == EAGAIN) || (errno == EWOULDBLOCK)) {
                BRTraceLog(@"%3d server EGAIN | EWOULDBLOCK", self.fd);
                break;
            }
            BRTraceLog(@"%3d ERROR accept client: %s", self.fd, strerror(errno));
            break;
        }
        getnameinfo(&in_addr, in_len, hbuf, sizeof(hbuf), sbuf, sizeof(sbuf), NI_NUMERICHOST | NI_NUMERICSERV);
        
        /* create client */
        BRClient *client = [[BRClient alloc] initWithFd:fd server:self addr:in_addr hostname:[NSString stringWithFormat:@"%s", hbuf] servname:[NSString stringWithFormat:@"%s", sbuf]];
        [client start_client];
        
        if (self.on_accept_client != nil) {
            self.on_accept_client(self, client);
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Server %@:%@", self.hostname, self.servname];
}

- (void)dealloc {
    BRTraceLog(@"DEALLOC SERVER %@", self);
}

@end
