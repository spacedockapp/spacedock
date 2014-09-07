//
//  DockSlot.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/7/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockTagged.h"

@class DockComponent, DockSlotted;

@interface DockSlot : DockTagged

@property (nonatomic, retain) DockComponent *component;
@property (nonatomic, retain) DockSlotted *owner;

@end
