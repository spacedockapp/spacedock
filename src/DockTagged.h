//
//  DockTagged.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/7/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockTag;

@interface DockTagged : NSManagedObject

@property (nonatomic, retain) NSSet *tags;
@end

@interface DockTagged (CoreDataGeneratedAccessors)

- (void)addTagsObject:(DockTag *)value;
- (void)removeTagsObject:(DockTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
