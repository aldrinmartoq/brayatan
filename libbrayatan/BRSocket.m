//
//  BRSocket.m
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/4/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "BRSocket.h"

@implementation BRSocket {
    brayatan_read_block     read_block;
    brayatan_write_block    write_block;
}

- (id) init {
    if (self = [super init]) {
        read_block = write_block = nil;
    }

    return self;
}

- (BOOL)setNonBlock {
    int flags, r;
    
    flags = fcntl(self.fd, F_GETFD, 0);
    if (flags == -1) {
        perror("fcntl F_GETFD");
        return NO;
    }
    
    flags |= O_NONBLOCK;
    r = fcntl(self.fd, F_SETFL, flags);
    if (r == -1) {
        perror("fcntl F_SETFL O_NONBLOCK O_CLOEXEC");
        return NO;
    }
    
    return YES;
}


- (void)read_start:(void(^)(void))handler {
    if (self.dispatch_source_read != nil) {
        return;
    }
    BRTraceLog(@"%@", self);
    self.dispatch_source_read = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, self.fd, 0, [BRSocket dispatch_queue]);
    dispatch_source_set_event_handler(self.dispatch_source_read, handler);
    dispatch_resume(self.dispatch_source_read);
}

- (void)read_cancel {
    if (self.dispatch_source_read != nil) {
        BRTraceLog(@"%@", self);
        dispatch_source_cancel(self.dispatch_source_read);
        dispatch_release(self.dispatch_source_read);
    }
    self.dispatch_source_read = nil;
}

- (void)write_start_Event:(void(^)(void))event_handler Cancel:(void(^)(void))cancel_handler {
    if (self.dispatch_source_write != nil) {
        return;
    }
    BRTraceLog(@"%@", self);
    self.dispatch_source_write = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, self.fd, 0, [BRSocket dispatch_queue]);
    dispatch_source_set_event_handler(self.dispatch_source_write, event_handler);
    dispatch_source_set_cancel_handler(self.dispatch_source_write, cancel_handler);
    dispatch_resume(self.dispatch_source_write);
}

- (void)write_cancel {
    if (self.dispatch_source_write != nil) {
        BRTraceLog(@"%@", self);
        dispatch_source_cancel(self.dispatch_source_write);
        dispatch_release(self.dispatch_source_write);
    }
    self.dispatch_source_write = nil;
}

- (void)setup_read:(brayatan_read_block)block {
    if (read_block == nil) {
        BRTraceLog(@"%@ setup read for %d", self, self.fd);
        read_block = block;
        brayatan_read_add(self.fd, read_block);
    } else {
        BRTraceLog(@"NO READ");
    }
}

- (void)cancel_read {
    if (read_block != nil) {
        BRTraceLog(@"%@ cancel read for %d", self, self.fd);
        brayatan_read_del(self.fd, read_block);
        read_block = nil;
    }
}

- (void)setup_write:(brayatan_write_block)block {
    if (write_block == nil) {
        BRTraceLog(@"%@ setup write for %d", self, self.fd);
        write_block = block;
        brayatan_write_add(self.fd, write_block);
    }
}

- (void)cancel_write {
    if (write_block != nil) {
        BRTraceLog(@"%@ cancel write for %d", self, self.fd);
        brayatan_write_del(self.fd, write_block);
        write_block = nil;
    }
}

- (void)fd_close {
    BRTraceLog(@"%@", self);
    close(self.fd);
    self.fd = -1;
}


+ (dispatch_queue_t) dispatch_queue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t dispatch_queue;
    dispatch_once(&onceToken, ^{
        dispatch_queue = dispatch_queue_create("brayatan", 0);
    });
    return dispatch_queue;
}

@end
