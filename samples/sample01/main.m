//
//  main.m
//  sample01
//
//  Created by Aldrin Martoq on 4/22/12.
//  Copyright (c) 2012 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Http.h"
#import "ObjCMongoDB.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSError *error = nil;
        MongoConnection *mongoConnection = [MongoConnection connectionForServer:@"127.0.0.1" error:&error];
        MongoDBCollection *collection = [mongoConnection collectionWithName:@"brayatan.datos"];
        Http *http = [Http createServerWithIP:@"0.0.0.0" atPort:@"8888" callback:^(Request *req, Response *res) {
            unsigned long long random = 0;
            arc4random_buf(&random, sizeof(random));

            if ([req.urlPath hasPrefix:@"/testing"]) {
                NSString *msg = [NSString stringWithFormat:@"Hola, Flaites!\r\npath: %@ host: %@\r\n", req.urlPath, req.host];
                [res setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
                [res appendStringToBodyBuffer:msg];
                [res send];
            } else if ([req.urlPath hasPrefix:@"/mongodb/create"]) {
                for (int i = 1; i <= 10; i++) {
                    [res appendFormatToBodyBuffer:@"Creating %ld - %lld\n", i, random];
                    NSError *error = nil;
                    NSDictionary *data = @{@"codigo" : [NSNumber numberWithUnsignedLongLong:random] , @"nombre" : [NSString stringWithFormat:@"dato %lld", random]};
                    [collection insertDictionary:data writeConcern:nil error:&error];
                    random++;
                }
                [res setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
                [res send];
            } else if ([req.urlPath hasPrefix:@"/mongodb/list"]) {
                MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                [predicate keyPath:@"codigo" isGreaterThan:[NSNumber numberWithUnsignedLongLong:random]];
                MongoFindRequest *findRequest = [MongoFindRequest findRequestWithPredicate:predicate];
                findRequest.limitResults = 10;
                
                NSError *error = nil;
                NSArray *results = [collection findWithRequest:findRequest error:&error];
                [res appendStringToBodyBuffer:@"Listado:\n"];
                NSUInteger i = 1;
                for (id o in results) {
                    [res appendFormatToBodyBuffer:@"%ld - %@\n", i, [BSONDecoder decodeDictionaryWithDocument:o]];
                    i++;
                }
                [res setHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
                [res appendFormatToBodyBuffer:@"Total: %ld\n", [results count]];
                [res send];
            } else {
                [res staticContentForRequest:req FromFolder:@"/var/www/test"];
            }
        }];

        NSLog(@"%@", http);
        [Http runloop];
    }

    return 0;
}
