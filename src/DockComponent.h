//
//  DockComponent.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/7/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSlotted.h"

@class DockSet, DockSlot;

@interface DockComponent : DockSlotted

@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * factionSortValue;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *sets;
@property (nonatomic, retain) NSSet *installs;
@end

@interface DockComponent (CoreDataGeneratedAccessors)

- (void)addSetsObject:(DockSet *)value;
- (void)removeSetsObject:(DockSet *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;

- (void)addInstallsObject:(DockSlot *)value;
- (void)removeInstallsObject:(DockSlot *)value;
- (void)addInstalls:(NSSet *)values;
- (void)removeInstalls:(NSSet *)values;

@end
