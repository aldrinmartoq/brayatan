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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        HttpDispatcher *dispatcher = [HttpDispatcher dispatcherWithIP:@"0.0.0.0" port:@"8888" templateFolder:@"/var/www/brayatan/sample03/"];
        [dispatcher addRoute:@"/mongo/" withController:[MongoController class]];
        [dispatcher addRoute:@"/test/" withController:[AdminController class]];
        NSLog(@"%@", dispatcher);
        [dispatcher runloop];
    }

    return 0;
}
