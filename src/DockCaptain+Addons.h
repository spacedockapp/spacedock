//
//  DockCaptain+Addons.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/28/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockCaptain.h"

@interface DockCaptain (Addons)
@property (nonatomic, readonly) int talentCount;
+(DockUpgrade*)zeroCostCaptain:(NSString*)faction context:(NSManagedObjectContext*)context;
@end
