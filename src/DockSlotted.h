//
//  DockSlotted.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/7/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockTagged.h"

@class DockSlot;

@interface DockSlotted : DockTagged

@property (nonatomic, retain) NSOrderedSet *slots;
@end

@interface DockSlotted (CoreDataGeneratedAccessors)

- (void)insertObject:(DockSlot *)value inSlotsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSlotsAtIndex:(NSUInteger)idx;
- (void)insertSlots:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSlotsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSlotsAtIndex:(NSUInteger)idx withObject:(DockSlot *)value;
- (void)replaceSlotsAtIndexes:(NSIndexSet *)indexes withSlots:(NSArray *)values;
- (void)addSlotsObject:(DockSlot *)value;
- (void)removeSlotsObject:(DockSlot *)value;
- (void)addSlots:(NSOrderedSet *)values;
- (void)removeSlots:(NSOrderedSet *)values;
@end
