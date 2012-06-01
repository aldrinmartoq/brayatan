//
//  main.m
//  sample02
//
//  Created by Aldrin Martoq on 5/15/12.
//  Copyright (c) 2012 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Http.h"
#import <sys/resource.h>
#import <sys/time.h>

struct timeval diff(struct timeval x, struct timeval y) {
    struct timeval r;
    if (x.tv_usec < y.tv_usec) {
        int s = (y.tv_usec - x.tv_usec) / 1000000 + 1;
        y.tv_usec -= 1000000 * s;
        y.tv_sec += s;
    }
    if (x.tv_usec - y.tv_usec > 1000000) {
        int s = (x.tv_usec - y.tv_usec) / 1000000;
        y.tv_usec += 1000000 * s;
        y.tv_sec -= s;
    }
    r.tv_sec = x.tv_sec - y.tv_sec;
    r.tv_usec = x.tv_usec - y.tv_usec;
    
    return r;
}

struct timeval time_start;
unsigned long long request_count = 0;

NSString *status() {
    struct rusage ru;
    getrusage(RUSAGE_SELF, &ru);
    unsigned long t1 = ru.ru_utime.tv_sec;
    unsigned long t2 = ru.ru_utime.tv_usec / 10000;
    unsigned long t3 = ru.ru_stime.tv_sec;
    unsigned long t4 = ru.ru_stime.tv_usec / 10000;
    
    struct timeval time_curr;
    gettimeofday(&time_curr, NULL);
    struct timeval r = diff(time_curr, time_start);
    unsigned long r1 = r.tv_sec;
    unsigned long r2 = r.tv_usec / 10000;
    
    unsigned long m1 = ru.ru_maxrss / 1024;
    
    return [NSString stringWithFormat:@"Hola, Flaites!\n\n--- Server status ---\nRequests: %llu\ncpu user: %ld.%02ld\ncpu  sys: %ld.%02ld\n  uptime: %ld.%02ld\nmem used: %ld KiB\n", request_count, t1, t2, t3, t4, r1, r2, m1];
}


int main(int argc, const char * argv[]) {
    gettimeofday(&time_start, NULL);
    @autoreleasepool {
        Http *http = [Http createServerWithIP:@"0.0.0.0" atPort:@"8888" callback:^(Request *req, Response *res) {
            request_count++;
            if ([req.urlPath hasPrefix:@"/status"]) {
                [res redirectToURL:@"/brayatan-status"];
            } else if ([req.urlPath hasPrefix:@"/brayatan-status"]) {
                /* show server status in /brayatan-status */
                [res setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
                [res endWithBody:status()];
            } else {
                /* mapping virtual host brayatan.org to static content in /var/www/brayatan/ */
                if ([req.host hasPrefix:@"brayatan.org"]) {
                    [res staticContentForRequest:req FromFolder:@"/var/www/brayatan/"];
                } else {
                    if ([req.urlPath hasPrefix:@"/javascripts/"]) {
                        /* alias /javascripts/ to /usr/share/javascripts/ */
                        [res staticContentForRequest:req FromFolder:@"/usr/share/"];
                    } else {
                        /* everything else should be in /var/www/ */
                        [res staticContentForRequest:req FromFolder:@"/var/www/"];
                    }
                }
            }
        }];

        NSLog(@"%@", http);
        [Http runloop];
    }

    return 0;
}
