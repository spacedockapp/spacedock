//
//  DockShip.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/24/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class DockEquippedShip;

@interface DockShip : NSManagedObject

@property (nonatomic, retain) NSString* ability;
@property (nonatomic, retain) NSNumber* agility;
@property (nonatomic, retain) NSNumber* attack;
@property (nonatomic, retain) NSNumber* battleStations;
@property (nonatomic, retain) NSNumber* cloak;
@property (nonatomic, retain) NSNumber* cost;
@property (nonatomic, retain) NSNumber* crew;
@property (nonatomic, retain) NSNumber* evasiveManeuvers;
@property (nonatomic, retain) NSString* externalId;
@property (nonatomic, retain) NSString* faction;
@property (nonatomic, retain) NSNumber* hull;
@property (nonatomic, retain) NSNumber* scan;
@property (nonatomic, retain) NSNumber* sensorEcho;
@property (nonatomic, retain) NSString* set;
@property (nonatomic, retain) NSNumber* shield;
@property (nonatomic, retain) NSString* shipClass;
@property (nonatomic, retain) NSNumber* targetLock;
@property (nonatomic, retain) NSNumber* tech;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSNumber* unique;
@property (nonatomic, retain) NSNumber* weapon;
@property (nonatomic, retain) NSSet* equippedShips;
@end

@interface DockShip (CoreDataGeneratedAccessors)

-(void)addEquippedShipsObject:(DockEquippedShip*)value;
-(void)removeEquippedShipsObject:(DockEquippedShip*)value;
-(void)addEquippedShips:(NSSet*)values;
-(void)removeEquippedShips:(NSSet*)values;

@end
