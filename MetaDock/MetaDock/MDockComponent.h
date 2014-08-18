//
//  MDockComponent.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/18/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MDockTaggable.h"

@class MDockCategory, MDockGameSystem;

@interface MDockComponent : MDockTaggable

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) MDockGameSystem *gameSystem;
@end

@interface MDockComponent (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(MDockCategory *)value;
- (void)removeCategoriesObject:(MDockCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
