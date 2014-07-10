//
//  MongoController.m
//  brayatan
//
//  Created by Aldrin Martoq on 5/24/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "MongoController.h"
#import "ObjCMongoDB.h"
#import "SBJson4.h"


@implementation NSDate (StringValue)

- (NSString *) stringValue {
    return [self descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone:nil locale:nil];
}

- (id)proxyForJson {
    return [self descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ" timeZone:nil locale:nil];
}
@end

@implementation BSONObjectID (JSON)
- (id)proxyForJson {
    return [self stringValue];
}
@end

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
    MongoDBCollection *collection = [MongoController collection];
    NSMutableArray *results = [NSMutableArray array];
    NSMutableArray *documents = [NSMutableArray array];
    for (int i = 1; i <=10; i++) {
        arc4random_buf(&random, sizeof(random));
        NSDictionary *data = @{@"_id" : [BSONObjectID objectID], @"codigo" : [NSNumber numberWithUnsignedLongLong:random] , @"nombre" : [NSString stringWithFormat:@"dato %llu", i + random], @"cuando" : [NSDate date]};
        [results addObject:data];
        [documents addObject:[data BSONDocument]];
    }
    
    NSError *error = nil;
    [collection insertDocuments:documents continueOnError:NO writeConcern:nil error:&error];

    NSDictionary *result = @{@"results" : results};
    SBJson4Writer *writer = [[SBJson4Writer alloc] init];
    return [writer stringWithObject:result];
}

- (id)listJSON {
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
        NSMutableDictionary *d = [[BSONDecoder decodeDictionaryWithDocument:[results objectAtIndex:i]] mutableCopy];
        [results setObject:d atIndexedSubscript:i];
    }
    
    NSDictionary *result = @{@"results" : results, @"cuenta" : [NSNumber numberWithUnsignedInteger:[results count]]};

    SBJson4Writer *writer = [[SBJson4Writer alloc] init];
    NSString *string = [writer stringWithObject:result];
    return string;
}

+ (MongoDBCollection *) collection {
    NSMutableDictionary *d = [[NSThread currentThread] threadDictionary];
    NSError *error = nil;
    MongoDBCollection *collection =  [d objectForKey:@0];
    if (collection == nil) {
        MongoConnection *mongoConnection = [MongoConnection connectionForServer:@"127.0.0.1" error:&error];
        collection = [mongoConnection collectionWithName:@"brayatan.datos"];
        [d setObject:collection forKey:@0];
    }
    
    return collection;
}

@end
