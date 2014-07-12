//
//  NSObject+MTJSONUtils.m
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/10/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "NSObject+MTJSONUtils.h"

@implementation NSObject (MTJSONUtils)

- (NSString *)a0JSONString {
    return [[NSString alloc] initWithData:[self a0JSONData] encoding:NSUTF8StringEncoding];
}

- (NSData *)a0JSONData
{
	return [NSJSONSerialization dataWithJSONObject:[self a0objectWithJSONSafeObjects] options:0 error:nil];
}

- (id)a0objectWithJSONSafeObjects
{
	if ([self isKindOfClass:[NSDictionary class]])
		return [self a0safeDictionaryFromDictionary:self];
    
	else if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]])
		return [self a0safeArrayFromArray:self];
    
	else
		return [self a0safeObjectFromObject:self];
}


- (id)a0valueForComplexKeyPath:(NSString *)keyPath {
    
	id currentObject = self;
    
	NSMutableString *path			= [NSMutableString string];
	NSMutableString *subscriptKey	= [NSMutableString string];
	NSMutableString *string			= path;
    
	for (int i = 0; i < keyPath.length; i++) {
        
		unichar c = [keyPath characterAtIndex:i];
        
		if (c == '[') {
			NSString *trimmedPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@". \n"]];
			currentObject = [currentObject valueForKeyPath:trimmedPath];
			[subscriptKey setString:@""];
			string = subscriptKey;
			continue;
		}
        
		if (c == ']') {
			if (!currentObject) return nil;
			if (![currentObject isKindOfClass:[NSArray class]]) return nil;
			NSUInteger index = 0;
			if ([subscriptKey isEqualToString:@"first"]) {
				index = 0;
			}
			else if ([subscriptKey isEqualToString:@"last"]) {
				index = [currentObject count] - 1;
			}
			else {
				index = [subscriptKey intValue];
			}
            if ([currentObject count] == 0) return nil;
			if (index > [currentObject count] - 1) return nil;
			currentObject = [currentObject objectAtIndex:index];
			if ([currentObject isKindOfClass:[NSNull class]]) return nil;
			[path setString:@""];
			string = path;
			continue;
		}
        
		[string appendString:[NSString stringWithCharacters:&c length:1]];
        
		if (i == keyPath.length - 1) {
			NSString *trimmedPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@". \n"]];
			currentObject = [currentObject valueForKeyPath:trimmedPath];
			break;
		}
	}
    
	return currentObject;
}

- (NSString *)a0stringValueForComplexKeyPath:(NSString *)key {
	id object = [self a0valueForComplexKeyPath:key];
    
	if ([object isKindOfClass:[NSString class]])
		return object;
    
	if ([object isKindOfClass:[NSNull class]])
		return @"";
    
	if ([object isKindOfClass:[NSNumber class]])
		return [object stringValue];
    
	if ([object isKindOfClass:[NSDate class]])
		return [NSString stringWithFormat:@"%@", [self a0safeObjectFromObject:object]];
    
	return [object description];
}





#pragma mark - Private Methods

- (id)a0safeDictionaryFromDictionary:(id)dictionary
{
    
	NSMutableDictionary *cleanDictionary = [NSMutableDictionary dictionary];
    
	for (id key in [dictionary allKeys]) {
		id object = [dictionary objectForKey:key];
        
		if ([object isKindOfClass:[NSDictionary class]])
			[cleanDictionary setObject:[object a0safeDictionaryFromDictionary:object] forKey:key];
        
		else if ([object isKindOfClass:[NSArray class]])
			[cleanDictionary setObject:[self a0safeArrayFromArray:object] forKey:key];
        
		else
			[cleanDictionary setObject:[self a0safeObjectFromObject:object] forKey:key];
	}
    
	return cleanDictionary;
}

- (id)a0safeArrayFromArray:(id)array
{
    
	NSMutableArray *cleanArray = [NSMutableArray array];
    
	for (id object in array) {
		if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSSet class]])
			[cleanArray addObject:[self a0safeArrayFromArray:object]];
        
		else if ([object isKindOfClass:[NSDictionary class]])
			[cleanArray addObject:[object a0safeDictionaryFromDictionary:object]];
        
		else
			[cleanArray addObject:[self a0safeObjectFromObject:object]];
	}
    
	return cleanArray;
}

- (id)a0safeObjectFromObject:(id)object {
    
	NSArray *validClasses = @[ [NSString class], [NSNumber class], [NSNull class] ];
	for (Class c in validClasses) {
		if ([object isKindOfClass:c])
			return object;
	}
    
	if ([object isKindOfClass:[NSDate class]]) {
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		NSString *ISOString = [formatter stringFromDate:object];
		return ISOString;
	}
    
	return [object description];
}

@end
