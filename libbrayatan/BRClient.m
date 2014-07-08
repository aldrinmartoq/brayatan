//
//  BRClient.m
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/4/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "BRClient.h"

@implementation BRClient

- (id)initWithFd:(int)fd server:(BRServer *)server addr:(struct sockaddr)in_addr hostname:(NSString *)hostname servname:(NSString *)servname {
    if (self = [super init]) {
        self.fd = fd;
        self.server = server;
        self.in_addr = in_addr;
        self.hostname = hostname;
        self.servname = servname;
        self.push_write_array = [[NSMutableArray alloc] init];

        BRDebugLog(@"%@ Client created", self);
    }
    return self;
}

- (void)start_client {
    [self setNonBlock];

    [self read_start:^{
        size_t length = dispatch_source_get_data(self.dispatch_source_read);
        BRTraceLog(@"%@ read available: %lu", self, length);
        if (length == 0) {
            [self stop_client];
        } else {
            void *buff = malloc(length);
            if (buff != NULL) {
                ssize_t count = read(self.fd, buff, length);
                if (count < 0) {
                    BRTraceLog(@"%@ read error: %s", self, strerror(errno));
                } else {
                    NSData *data = [[NSData alloc] initWithBytes:buff length:count];
                    if (self.server.on_read_client != nil) {
                        self.server.on_read_client(self.server, self, data);
                    }
                }
                free(buff);
            }
        }
    }];
}

- (void)stop_client {
    BRTraceLog(@"%@", self);
    [self read_cancel];
    [self write_cancel];
    [self fd_close];
    if (self.server.on_close_client != nil) {
        self.server.on_close_client(self.server, self);
    }
}

- (void)push_write:(BRClientWriteBlock)block {
        if (self.push_write_array == nil) {
            self.push_write_array = [[NSMutableArray alloc] initWithObjects:block, nil];
            BRTraceLog(@"%@ write create array: %@", self, self.push_write_array);
        } else {
            [self.push_write_array addObject:block];
            BRTraceLog(@"%@ write add length:%ld array: %@", self, [self.push_write_array count], self.push_write_array);
        }
        [self write_start_Event:^{
            size_t length = dispatch_source_get_data(self.dispatch_source_write);
            BRTraceLog(@"%@ write available: %lu array length:%ld", self, length, [self.push_write_array count]);
            if (length == 0) {
                [self stop_client];
            } else {
                BRClientWriteBlock block = [self.push_write_array firstObject];
                if (block == nil) {
                    BRErrorLog(@"NIL BLOCK IN WRITE");
                    return;
                }
                brayatan_write_block_result result = block(self, length);
                if (result == kBrayatanWriteBlockCont) {
                    BRTraceLog(@"%@ block: continue", self);
                } else if (result == kBrayatanWriteBlockNext) {
                    BRTraceLog(@"%@ block: next", self);
                    [self.push_write_array removeObjectAtIndex:0];
                    if ([self.push_write_array count] == 0) {
                        [self write_cancel];
                    }
                } else if (result == kBrayatanWriteBlockDone) {
                    BRTraceLog(@"%@ block: done", self);
                    [self stop_client];
                }
            }
        } Cancel:^{
            BRTraceLog(@"%@ Cleaning up…", self);
            for (BRClientWriteBlock block in self.push_write_array) {
                if (block == nil) {
                    BRErrorLog(@"NIL BLOCK IN CANCEL");
                } else {
                    block(self, 0);
                }
            }
        }];
}

- (void)write_data:(NSData *)data {
    __block off_t offset = 0;
    __block NSUInteger data_length = [data length];
    [self push_write:^brayatan_write_block_result(BRClient *client, size_t length) {
        if (length <=0) {
            BRTraceLog(@"%@ next because length: %lu", self, length);
            return kBrayatanWriteBlockNext;
        }
        const void *bytes = [data bytes];
        bytes += offset;
        size_t write_length = data_length - offset;
        if (write_length > length) {
            write_length = length;
        }
        ssize_t r = write(self.fd, bytes, write_length);
        BRTraceLog(@"%@ data_length: %ld offset: %lld write_length: %ld r: %ld", self, data_length, offset, write_length, r);
        if (r == -1) {
            BRErrorLog(@"%@ WRITE ERROR: %s", self, strerror(errno));
            return kBrayatanWriteBlockDone;
        } else if (r < write_length) {
            offset += r;
            return kBrayatanWriteBlockCont;
        } else {
            return kBrayatanWriteBlockNext;
        }
    }];
}

- (void)write_string:(NSString *)string {
    BRTraceLog(@"%@ string: %@", self, string);
    [self write_data:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)write_file:(NSString *)path onOpen:(BRClientSendfileOnOpenBlock)on_open onError:(BRClientSendfileOnErrorBlock)on_error {
    BRTraceLog(@"%@ path: %@", self, path);
    __block int fd = open([path UTF8String], O_RDONLY);
    if (fd == -1) {
        on_error(errno);
        return;
    }
    
    struct stat stat;
    int r = fstat(fd, &stat);
    if (r == -1) {
        on_error(errno);
        close(fd);
        return;
    }
    
    if (on_open(stat) == NO) {
        close(fd);
        return;
    }
    
    __block size_t offset = 0;
    [self push_write:^brayatan_write_block_result(BRClient *client, size_t length) {
        if (length <= 0) {
            BRTraceLog(@"%@ next because length: %lu, closing sendfile", self, length);
            close(fd);
            fd = -1;
            return kBrayatanWriteBlockNext;
        }
        BRTraceLog(@"%@ send file before offset: %ld length: %lu", self, offset, length);
        off_t size = length;
        int r = sendfile(fd, self.fd, offset, &size, NULL, 0);
        offset += size;
        if (r == -1) {
            if (size != 0 && (errno = EAGAIN || errno == EWOULDBLOCK)) {
                BRTraceLog(@"%@ send file WOULDBLOCK offset: %ld length: %lld", self, offset, size);
                return kBrayatanWriteBlockCont;
            } else {
                BRTraceLog(@"%@ send file ERROR offset: %ld length: %lld error: %s", self, offset, size,strerror(errno));
                close(fd);
                fd = -1;
                return kBrayatanWriteBlockDone;
            }
        }
        BRTraceLog(@"%@ send file after  offset: %ld length: %lld", self, offset, size);
        if (size == 0) {
            close(fd);
            fd = -1;
            BRTraceLog(@"%@ send file closing", self);
            return kBrayatanWriteBlockNext;
        }
        return kBrayatanWriteBlockCont;
    }];
}

- (void)write_close {
    BRTraceLog(@"%@ close", self);
    [self push_write:^brayatan_write_block_result(BRClient *client, size_t length) {
        return kBrayatanWriteBlockDone;
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Client %@:%@", self.hostname, self.servname];
}

- (void)dealloc {
    BRTraceLog(@"%@ DEALLOC", self);
}

@end
