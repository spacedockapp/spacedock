//
//  DockEquippedUpgrade.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/28/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class DockEquippedShip, DockUpgrade;

@interface DockEquippedUpgrade : NSManagedObject

@property (nonatomic, retain) DockEquippedShip* equippedShip;
@property (nonatomic, retain) DockUpgrade* upgrade;

@end
