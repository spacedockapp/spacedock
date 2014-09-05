//
//  DockComponent.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/4/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockTagged.h"

@class DockSet, DockSlot;

@interface DockComponent : DockTagged

@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * factionSortValue;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *sets;
@property (nonatomic, retain) NSSet *slots;
@end

@interface DockComponent (CoreDataGeneratedAccessors)

- (void)addSetsObject:(DockSet *)value;
- (void)removeSetsObject:(DockSet *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;

- (void)addSlotsObject:(DockSlot *)value;
- (void)removeSlotsObject:(DockSlot *)value;
- (void)addSlots:(NSSet *)values;
- (void)removeSlots:(NSSet *)values;

@end
