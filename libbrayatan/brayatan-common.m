//
//  brayatan-common.m
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/6/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "brayatan-common.h"
#import <assert.h>
#import <pthread.h>
#import <sys/event.h>
#import "BRSocket.h"

NSString *br_time_fmt_gmt(time_t t) {
    static char *week[7] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
    static char *month[12] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
    struct tm *gtm = gmtime(&t);
    gtm->tm_year += 1900;
    return [NSString stringWithFormat:@"%s, %02d %s %d %02d:%02d:%02d GMT", week[gtm->tm_wday], gtm->tm_mday, month[gtm->tm_mon], gtm->tm_year, gtm->tm_hour, gtm->tm_min, gtm->tm_sec];
}

NSString *br_time_fmt_gmt_now() {
    return br_time_fmt_gmt(time(NULL));
}

static int kq;

void brayatan_init() {
    kq = kqueue();
    if (kq == -1) {
        perror("kqueue");
        abort();
    }
}

void brayatan_read_add(int fd, brayatan_read_block block) {
    struct kevent ke;
    memset(&ke, 0, sizeof(struct kevent));

    EV_SET(&ke, fd, EVFILT_READ, EV_ADD, 0, 0, (__bridge void *)block);
    int r = kevent(kq, &ke, 1, NULL, 0, NULL);
    if (r == -1) {
        perror("kevent");
        abort();
    }
}

void brayatan_read_del(int fd, brayatan_read_block block) {
    struct kevent ke;
    memset(&ke, 0, sizeof(struct kevent));
    
    EV_SET(&ke, fd, EVFILT_READ, EV_ADD, 0, 0, (__bridge void *)block);
    int r = kevent(kq, &ke, 1, NULL, 0, NULL);
    if (r == -1) {
        perror("kevent");
        abort();
    }
}

void brayatan_write_add(int fd, brayatan_write_block block) {
    struct kevent ke;
    memset(&ke, 0, sizeof(struct kevent));
    
    EV_SET(&ke, fd, EVFILT_WRITE, EV_ADD, 0, 0, (__bridge void *)block);
    int r = kevent(kq, &ke, 1, NULL, 0, NULL);
    if (r == -1) {
        perror("kevent");
        abort();
    }
}

void brayatan_write_del(int fd, brayatan_read_block block) {
    struct kevent ke;
    memset(&ke, 0, sizeof(struct kevent));
    
    EV_SET(&ke, fd, EVFILT_WRITE, EV_DELETE, 0, 0, (__bridge void *)block);
    int r = kevent(kq, &ke, 1, NULL, 0, NULL);
    if (r == -1) {
        perror("kevent");
        abort();
    }
}

static void *_brayatan_run_loop_main(void *data) {
    struct kevent *kevents = NULL;
    kevents = calloc(128, sizeof(struct kevent));
    if (kevents == NULL) {
        perror("calloc kevents");
        abort();
    }
    
    while (true) {
        struct timespec kqtimeout;
        kqtimeout.tv_sec = 5;
        kqtimeout.tv_nsec = 0;
        memset(kevents, 0, 128 * sizeof(struct kevent));
        int n = kevent(kq, NULL, 0, kevents, 128, &kqtimeout);
        if (n == -1) {
            BRErrorLog(@"ERROR ON kevent: %s", strerror(errno));
        } else if (n == 0) {
            BRInforLog(@"Timeout.");
        } else {
            BRInforLog(@"GOT events: %d", n);
        }
        for (int i = 0; i < n; i++) {
            struct kevent kevent = kevents[i];
            if (kevent.filter == EVFILT_READ) {
                BRTraceLog(@"READ length: %ld", kevent.data);
                brayatan_read_block block = (__bridge brayatan_read_block)kevent.udata;
                block(kevent.data);
            }
            if (kevent.filter == EVFILT_WRITE) {
                BRTraceLog(@"WRITE length: %ld", kevent.data);
                brayatan_write_block block = (__bridge brayatan_write_block)kevent.udata;
                block(kevent.data);
            }
        }
    }
    return NULL;
}

void brayatan_run_loop() {
    pthread_attr_t  attr;
    pthread_t       thread;
    int             ret;
    
    ret = pthread_attr_init(&attr);
    assert(!ret);
    ret = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!ret);

    int threadError = pthread_create(&thread, &attr, &_brayatan_run_loop_main, NULL);
    if (threadError != 0) {
        perror("pthread_create");
        abort();
    }
    ret = pthread_attr_destroy(&attr);
    assert(!ret);
    dispatch_main();
}