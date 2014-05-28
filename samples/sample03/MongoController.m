//
//  MongoController.m
//  brayatan
//
//  Created by Aldrin Martoq on 5/24/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "MongoController.h"
#import "ObjCMongoDB.h"

@implementation MongoController

- (id)list {
    unsigned long long random = 0;
    arc4random_buf(&random, sizeof(random));
    NSError *error = nil;
    MongoDBCollection *collection = [MongoController collection];
    MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
    [predicate keyPath:@"codigo" isGreaterThan:[NSNumber numberWithUnsignedLongLong:random]];
    MongoFindRequest *findRequest = [MongoFindRequest findRequestWithPredicate:predicate];
    findRequest.limitResults = 10;
    NSMutableArray *results = [[collection findWithRequest:findRequest error:&error] mutableCopy];
    for (NSUInteger i = 0; i < [results count]; i++) {
        [results setObject:[BSONDecoder decodeDictionaryWithDocument:[results objectAtIndex:i]] atIndexedSubscript:i];
    }

    if (results != nil) {
        return @{@"results" : results, @"cuenta" : [NSNumber numberWithUnsignedInteger:[results count]]};
    } else {
        return @{};
    }
}

- (id)create {
    unsigned long long random = 0;
    arc4random_buf(&random, sizeof(random));
    MongoDBCollection *collection = [MongoController collection];
    for (int i = 1; i <=10; i++) {
        NSError *error = nil;
        NSDictionary *data = @{@"codigo" : [NSNumber numberWithUnsignedLongLong:random] , @"nombre" : [NSString stringWithFormat:@"dato %llu", i + random]};
        [collection insertDictionary:data writeConcern:nil error:&error];
    }
    
    return [NSString stringWithFormat:@"OK %llu", random];
}

+ (MongoDBCollection *) collection {
    static MongoDBCollection *collection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        MongoConnection *mongoConnection = [MongoConnection connectionForServer:@"127.0.0.1" error:&error];
        collection = [mongoConnection collectionWithName:@"brayatan.datos"];
    });
    
    return collection;
}

@end
