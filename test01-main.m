//
//  test01-main.m
//  brayatan
//
//  Created by Aldrin Martoq on 7/3/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "BRServer.h"

int main(int argc, char **argv) {
    __block int count = 0;
    
    BRServer *server = [[BRServer alloc] initWithHostname:@"0.0.0.0" serviceName:@"8080"];

    server.on_accept_client =  ^void(BRServer *server, BRClient *client) {
        count++;
        
        if (count == 3) {
//            [server stop];
        }
    };
    
    server.on_read_client = ^void(BRServer *server, BRClient *client, NSData *data) {
        NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        BRDebugLog(@"%@ GOT: %@", client, s);
        if ([s hasPrefix:@"G"]) {
            [client write_file:@"/tmp/ya.html" onOpen:^BOOL(struct stat stat) {
                return YES;
            } onError:^(int err) {
                BRErrorLog(@"%@ FATAL ERROR: %s", client, strerror(err));
            }];
            [client write_close];
        }
        
        
        return;
        BRDebugLog(@"GOT: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        char buff[1024];
        sprintf(buff, "HTTP/1.1 200 OK \n\
Date: Fri, 04 Jul 2014 10:31:17 GMT \n\
Server: Apache/2.2.26 (Unix) DAV/2 PHP/5.4.24 mod_ssl/2.2.26 OpenSSL/0.9.8y \n\
Content-Location: index.html.en \n\
Vary: negotiate \n\
TCN: choice \n\
Last-Modified: Tue, 02 Apr 2013 13:19:09 GMT \n\
Accept-Ranges: bytes \n\
Connection: close \n\
Content-Type: text/html \n\
Content-Language: en \n\
\n\
HOLA %d\n\
", count);
        write(client.fd, buff, strlen(buff));
        [client stop_client];
   };
    
    server.on_close_client = ^void(BRServer *server, BRClient *client) {
        BRDebugLog(@"CLOSE: %@", client);
    };
    
    [server start_server];
    
//    brayatan_server_create("0.0.0.0", "8080", ^(brayatan_server_t *server, brayatan_client_t *client) {
//        /* on_client_accept */
//        brayatan_infor_log("CLIENT ACCEPT %s:%s", client->sock.hbuf, client->sock.sbuf);
//        char buff[1024];
//        count++;
//        sprintf(buff, "count: %d\n", count);
//        write(client->sock.fd, buff, strlen(buff));
//        if (count == 2) {
//            brayatan_server_close(server);
//        }
//    }, ^(brayatan_client_t *client, char *buffer, size_t length) {
//        /* on_client_read */
//        brayatan_infor_log("CLIENT READ   %s:%s length: %d\n%.*s", client->sock.hbuf, client->sock.sbuf, length, length, buffer);
//        brayatan_client_sendfile(client, "/tmp/ok", ^BOOL(struct stat stat) {
//            return YES;
//        }, ^(int err) {
//            brayatan_infor_log("ERROR ON SENDFILE %s", strerror(err));
//        });
//        brayatan_client_close(client);
//    }, ^(brayatan_client_t *client) {
//        /* on_client_close */
//        brayatan_infor_log("CLIENT CLOSE  %s:%s", client->sock.hbuf, client->sock.sbuf);
//    }, ^(brayatan_server_t *server) {
//        /* on_server_close */
//        brayatan_infor_log("SERVER CLOSE  %s:%s ", server->sock.hbuf, server->sock.sbuf);
//    });
//    
    dispatch_main();
//    brayatan_main_loop();
}