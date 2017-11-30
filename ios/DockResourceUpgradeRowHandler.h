//
//  DockResourceUpgradeRowHandler.h
//  Space Dock iOS
//
//  Created by Robert George on 11/29/17.
//  Copyright © 2017 Robert George. All rights reserved.
//

#import "DockRowHandler.h"

@class DockEquippedShip;

@interface DockResourceUpgradeRowHandler : DockRowHandler
@property (strong, nonatomic) DockEquippedShip* equippedShip;
@end
