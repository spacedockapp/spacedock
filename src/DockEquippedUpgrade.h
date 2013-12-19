//
//  DockEquippedUpgrade.h
//  Space Dock
//
//  Created by Rob Tsuk on 12/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockEquippedShip, DockUpgrade;

@interface DockEquippedUpgrade : NSManagedObject

@property (nonatomic, retain) DockEquippedShip *equippedShip;
@property (nonatomic, retain) DockUpgrade *upgrade;

@end
