//
//  DockUpgrade.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/24/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockEquippedShip;

@interface DockUpgrade : NSManagedObject

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * faction;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unique;
@property (nonatomic, retain) NSString * upType;
@property (nonatomic, retain) NSSet *equippedShips;
@end

@interface DockUpgrade (CoreDataGeneratedAccessors)

- (void)addEquippedShipsObject:(DockEquippedShip *)value;
- (void)removeEquippedShipsObject:(DockEquippedShip *)value;
- (void)addEquippedShips:(NSSet *)values;
- (void)removeEquippedShips:(NSSet *)values;

@end
