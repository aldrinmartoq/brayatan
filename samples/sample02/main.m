//
//  main.m
//  sample02
//
//  Created by Aldrin Martoq on 5/15/12.
//  Copyright (c) 2012 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Http.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block Http *http = [Http createServerWithIP:@"0.0.0.0" atPort:@"8888" callback:^(Request *req, Response *res) {
            if ([req.urlPath hasPrefix:@"/status"]) {
                [res redirectToURL:@"/brayatan-status"];
            } else if ([req.urlPath hasPrefix:@"/brayatan-status"]) {
                /* show server status in /brayatan-status */
                [res setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
                [res endWithBody:[http statusString]];
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
