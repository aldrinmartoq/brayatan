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
        Http *http = [Http createServerWithIP:@"0.0.0.0" atPort:8888 callback:^(Request *req, Response *res) {
            [res setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
            [res endWithBody:@"Hola, Flaites!"];
        }];
        
        NSLog(@"%@", http);
        uv_run(uv_default_loop());
    }
    return 0;
}
