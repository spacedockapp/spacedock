//
//  MDockTag.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/23/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MDockGameSystem, MDockTaggable;

@interface MDockTag : NSManagedObject

@property (nonatomic, retain) MDockGameSystem *gameSystem;
@property (nonatomic, retain) NSSet *tagged;
@end

@interface MDockTag (CoreDataGeneratedAccessors)

- (void)addTaggedObject:(MDockTaggable *)value;
- (void)removeTaggedObject:(MDockTaggable *)value;
- (void)addTagged:(NSSet *)values;
- (void)removeTagged:(NSSet *)values;

@end
