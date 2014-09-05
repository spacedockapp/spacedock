//
//  DockSquad.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/4/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSlotted.h"

@class DockEquippedShip, DockResource;

@interface DockSquad : DockSlotted

@property (nonatomic, retain) NSNumber * additionalPoints;
@property (nonatomic, retain) NSDate * modified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSOrderedSet *equippedShips;
@property (nonatomic, retain) DockResource *resource;
@end

@interface DockSquad (CoreDataGeneratedAccessors)

- (void)insertObject:(DockEquippedShip *)value inEquippedShipsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEquippedShipsAtIndex:(NSUInteger)idx;
- (void)insertEquippedShips:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEquippedShipsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEquippedShipsAtIndex:(NSUInteger)idx withObject:(DockEquippedShip *)value;
- (void)replaceEquippedShipsAtIndexes:(NSIndexSet *)indexes withEquippedShips:(NSArray *)values;
- (void)addEquippedShipsObject:(DockEquippedShip *)value;
- (void)removeEquippedShipsObject:(DockEquippedShip *)value;
- (void)addEquippedShips:(NSOrderedSet *)values;
- (void)removeEquippedShips:(NSOrderedSet *)values;
@end
