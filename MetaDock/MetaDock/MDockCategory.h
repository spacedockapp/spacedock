//
//  MDockCategory.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/23/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MDockTaggable.h"

@class MDockComponent, MDockGameSystem;

@interface MDockCategory : MDockTaggable

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSSet *components;
@property (nonatomic, retain) MDockGameSystem *gameSystem;
@end

@interface MDockCategory (CoreDataGeneratedAccessors)

- (void)addComponentsObject:(MDockComponent *)value;
- (void)removeComponentsObject:(MDockComponent *)value;
- (void)addComponents:(NSSet *)values;
- (void)removeComponents:(NSSet *)values;

@end
