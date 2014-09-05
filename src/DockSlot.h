//
//  DockSlot.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/4/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockTagged.h"

@class DockComponent, DockSlotted;

@interface DockSlot : DockTagged

@property (nonatomic, retain) DockSlotted *owner;
@property (nonatomic, retain) DockComponent *contents;

@end
