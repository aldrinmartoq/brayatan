//
//  brayatan-core.h
//  libbrayatan
//
//  Created by Aldrin Martoq on 5/14/12.
//  Copyright (c) 2012 A0. All rights reserved.
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
#include <dispatch/dispatch.h>


#define BR_LOG_TRA_ENABLED 0
#define BR_LOG_DEB_ENABLED 0
#define BR_LOG_INF_ENABLED 1
#define BR_LOG_ERR_ENABLED 1

#define BRSOCKET_SERVER 0
#define BRSOCKET_CLIENT 1

#define BRSOCKET_WATCH_READ         0x01
#define BRSOCKET_WATCH_WRITE        0x02
#define BRSOCKET_WATCH_READWRITE    0x03
#define BRLOOP_SCK_ARR_LEN 8192

typedef struct br_loop {
    int qfd;
    unsigned int usage;
    struct br_socket *sockets[BRLOOP_SCK_ARR_LEN];
    int sockets_len;
} br_loop_t;

typedef struct br_socket {
    int type;
    unsigned int usage;
    int fd;
    br_loop_t *loop;
    struct sockaddr in_addr;
    char hbuf[NI_MAXHOST], sbuf[NI_MAXSERV];
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

void br_log(char level, char *fmt, va_list ap);
void br_log_trace(char *fmt, ...);
void br_log_debug(char *fmt, ...);
void br_log_info(char *fmt, ...);
void br_log_error(char *fmt, ...);

void br_socket_addwatch(br_socket_t *s, int mode);
void br_socket_delwatch(br_socket_t *s, int mode);

char *br_time_curr_gmt();
NSString *br_time_fmt_gmt(struct timespec t);

br_loop_t *br_loop_create();

br_server_t *br_server_create(br_loop_t *loop, char *hostname, char *servname, void (^on_accept)(br_client_t *), void (^on_read)(br_client_t *, char *, size_t), void (^on_close)(br_client_t *), void (^on_release)(br_server_t *));
void br_client_close(br_client_t *c);
void br_client_write(br_client_t *c, char *buff, size_t buff_len, void (^on_error)(br_client_t *));
void br_client_sendfile(br_client_t *c, char *path, BOOL (^on_open)(br_client_t *, struct stat stat), void (^on_open_error)(br_client_t *c, int err));

void br_runloop(br_loop_t *loop);
