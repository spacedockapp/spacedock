//
//  DockTagged.h
//  Space Dock
//
//  Created by Rob Tsuk on 8/24/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface DockTagged : NSManagedObject

@property (nonatomic, retain) NSSet *tags;
@end

@interface DockTagged (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
