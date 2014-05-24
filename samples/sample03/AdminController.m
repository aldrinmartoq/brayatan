//
//  AdminController.m
//  brayatan
//
//  Created by Aldrin Martoq on 5/22/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "AdminController.h"

@implementation AdminController

- (id)hola {
    return @"ok";
}

- (id)chao {
    return @{@"texto": @"1", @"numero" : @2, @"lista" : @[@{@"x" : @1},@{@"x" : @2},@{@"x" : @3}]};
}

@end
