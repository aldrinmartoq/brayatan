//
//  MongoTest.m
//  ObjCMongoDB
//
//  Copyright 2012 Paul Melnikow and other contributors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MongoTest.h"
#import "MongoConnection.h"
#import "BSON_Helper.h"

@implementation MongoTest

-(void) setUp {
    NSError *error = nil;
    self.mongo = [MongoConnection connectionForServer:@"127.0.0.1:27017" error:&error];
    XCTAssertNotNil(self.mongo);
    XCTAssertNil(error);
}

- (void) tearDown {
    [self.mongo disconnect];
    maybe_release(_mongo);
}

@end
