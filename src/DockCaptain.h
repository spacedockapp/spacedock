//
//  DockCaptain.h
//  Space Dock
//
//  Created by Rob Tsuk on 12/18/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockUpgrade.h"


@interface DockCaptain : DockUpgrade

@property (nonatomic, retain) NSNumber * skill;
@property (nonatomic, retain) NSNumber * talent;

@end
