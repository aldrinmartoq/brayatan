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

int main(int argc, const char * argv[], char **envp) {
    printf("\n");
    char** env;
    for (env = envp; *env != 0; env++)
    {
        char* thisEnv = *env;
        printf("export %s\n", thisEnv);
    }
    printf("\n");
    printf("%s > brayatan2.log 2>&1 &\n", argv[0]);
    printf("\n");
    printf("\n");

    
    @autoreleasepool {
        NSString *templateFolder = [NSString stringWithFormat:@"%@/views", [[NSBundle mainBundle] resourcePath]];
        HttpDispatcher *dispatcher = [HttpDispatcher dispatcherWithIP:@"0.0.0.0" port:@"9999" templateFolder:templateFolder];
        [dispatcher addRoute:@"/mongo/" withController:[MongoController class]];
        [dispatcher addRoute:@"/test/" withController:[AdminController class]];
        NSLog(@"%@", dispatcher);
        [dispatcher runloop];
    }

    return 0;
}
