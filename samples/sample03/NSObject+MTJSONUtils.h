//
//  NSObject+MTJSONUtils.h
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/10/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MTJSONUtils)

- (NSString *)a0JSONString;
- (NSData *)a0JSONData;
- (id)a0objectWithJSONSafeObjects;
- (id)a0valueForComplexKeyPath:(NSString *)keyPath;
- (NSString *)a0stringValueForComplexKeyPath:(NSString *)key;

@end
