//
//  CDPerson.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+BSONCoding.h"

@class CDPerson;

@interface CDPerson : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * dob;
@property (nonatomic, retain) NSNumber * numberOfVisits;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) CDPerson *parent;

-(BOOL)isEqualForTesting:(CDPerson *) obj;

@end



@interface CDPerson (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(CDPerson *)value;
- (void)removeChildrenObject:(CDPerson *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
