//
//  HttpDispatcher.h
//  libbrayatan
//
//  Created by Aldrin Martoq on 5/22/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpController.h"

@interface HttpDispatcher : NSObject

- (void)addRoute:(NSString *)route withController:(Class)controller;
- (void)addRoute:(NSString *)route withStaticContentFromFolder:(NSString *)folder;
- (void)runloop;
+ (instancetype)dispatcherWithIP:(NSString *)ip port:(NSString *)port templateFolder:(NSString *)templateFolder;

@end
