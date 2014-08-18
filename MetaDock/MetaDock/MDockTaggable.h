//
//  MDockTaggable.h
//  MetaDock
//
//  Created by Rob Tsuk on 8/18/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MDockTag;

@interface MDockTaggable : NSManagedObject

@property (nonatomic, retain) NSSet *tags;
@end

@interface MDockTaggable (CoreDataGeneratedAccessors)

- (void)addTagsObject:(MDockTag *)value;
- (void)removeTagsObject:(MDockTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
