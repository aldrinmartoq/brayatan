//
//  main.m
//  sample01
//
//  Created by Aldrin Martoq on 4/22/12.
//  Copyright (c) 2012 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Http.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Http *http = [Http createServerWithIP:@"0.0.0.0" atPort:@"8888" callback:^(Request *req, Response *res) {

            if ([req.urlPath hasPrefix:@"/testing"]) {
                NSString *msg = [NSString stringWithFormat:@"Hola, Flaites!\r\npath: %@ host: %@\r\n", req.urlPath, req.host];
                [res setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
                [res endWithBody:msg];
            } else {
                [res staticContentForPath:req.urlPath FromFolder:@"/var/www/test"];
            }
        }];

        NSLog(@"%@", http);
        [Http runloop];
    }

    return 0;
}
