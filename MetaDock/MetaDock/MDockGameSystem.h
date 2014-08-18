//
//  MDockGameSystem.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/17/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MDockCategory, MDockComponent, MDockTag;

@interface MDockGameSystem : NSManagedObject

@property (nonatomic, retain) NSString * systemId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) id terms;
@property (nonatomic, retain) NSSet *components;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *categories;
@end

@interface MDockGameSystem (CoreDataGeneratedAccessors)

- (void)addComponentsObject:(MDockComponent *)value;
- (void)removeComponentsObject:(MDockComponent *)value;
- (void)addComponents:(NSSet *)values;
- (void)removeComponents:(NSSet *)values;

- (void)addTagsObject:(MDockTag *)value;
- (void)removeTagsObject:(MDockTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addCategoriesObject:(MDockCategory *)value;
- (void)removeCategoriesObject:(MDockCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
