//
//  DockCaptain.h
//  Space Dock
//
//  Created by Rob Tsuk on 4/12/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockUpgrade.h"


@interface DockCaptain : DockUpgrade

@property (nonatomic, retain) NSNumber * skill;
@property (nonatomic, retain) NSNumber * talent;

@end
