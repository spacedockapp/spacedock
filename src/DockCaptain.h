//
//  DockCaptain.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/28/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockUpgrade.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface DockCaptain : DockUpgrade

@property (nonatomic, retain) NSNumber* skill;
@property (nonatomic, retain) NSNumber* talent;

@end
