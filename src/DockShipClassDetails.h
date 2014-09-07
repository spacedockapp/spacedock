//
//  DockShipClassDetails.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/7/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockManeuver, DockShip;

@interface DockShipClassDetails : NSManagedObject

@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * frontArc;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * rearArc;
@property (nonatomic, retain) NSSet *maneuvers;
@property (nonatomic, retain) NSSet *ships;
@end

@interface DockShipClassDetails (CoreDataGeneratedAccessors)

- (void)addManeuversObject:(DockManeuver *)value;
- (void)removeManeuversObject:(DockManeuver *)value;
- (void)addManeuvers:(NSSet *)values;
- (void)removeManeuvers:(NSSet *)values;

- (void)addShipsObject:(DockShip *)value;
- (void)removeShipsObject:(DockShip *)value;
- (void)addShips:(NSSet *)values;
- (void)removeShips:(NSSet *)values;

@end
