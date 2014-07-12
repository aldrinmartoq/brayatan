//
//  main.m
//  sample03
//
//  Created by Aldrin Martoq on 5/22/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpDispatcher.h"
#import "AdminController.h"
#import "MongoController.h"
#import "brayatan-core.h"

static char *response = "HTTP/1.1 200 OK \n\
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
";

void server_test() {
    __block int count = 0;
    br_loop_t *loop = br_loop_create();
    br_server_create(loop, "0.0.0.0", "8888", ^(br_client_t *client) {
        /* on accept */
        br_log_debug("ACCEPT: %s:%s", client->sock.hbuf, client->sock.sbuf);
        count++;
        br_socket_addwatch((br_socket_t *)client, BRSOCKET_WATCH_READ);
    }, ^(br_client_t *client, char *buff, size_t length) {
        /* on read */
        br_log_debug("READ  : %s:%s %.*s", client->sock.hbuf, client->sock.sbuf, length, buff);
        if (length > 0 && buff[0] == 'G') {
            br_client_write(client, response, strlen(response), ^(br_client_t *client) {
                br_log_error("ERROR: ON WRITE");
            });
        }
        br_client_close(client);
    }, ^(br_client_t *client) {
        /* on close */
        br_log_debug("CLOSE : %s:%s", client->sock.hbuf, client->sock.sbuf);
    }, ^(br_server_t *server) {
        /* on release */
        br_log_debug("RELEASE : %s:%s", server->sock.hbuf, server->sock.sbuf);
    });
    br_runloop(loop);
}


int main(int argc, const char * argv[], char** envp) {
    printf("\n");
    char** env;
    for (env = envp; *env != 0; env++)
    {
        char* thisEnv = *env;
        printf("export %s\n", thisEnv);
    }
    printf("\n");
    printf("%s > brayatan.og 2>&1 &\n", argv[0]);

    printf("\n");
    printf("\n");
    @autoreleasepool {
        NSString *templateFolder = [NSString stringWithFormat:@"%@/views", [[NSBundle mainBundle] resourcePath]];
        HttpDispatcher *dispatcher = [HttpDispatcher dispatcherWithIP:@"0.0.0.0" port:@"8888" templateFolder:templateFolder];
        [dispatcher addRoute:@"/mongo/" withController:[MongoController class]];
        [dispatcher addRoute:@"/test/" withController:[AdminController class]];
        NSLog(@"%@", dispatcher);
        [dispatcher runloop];
    }

    return 0;
}
