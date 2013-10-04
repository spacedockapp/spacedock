//
//  DockShip+Addons.h
//  Space Dock
//
//  Created by Rob Tsuk on 9/27/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockShip.h"

@interface DockShip (Addons)
+(DockShip*)shipForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
-(BOOL)isBreen;
-(BOOL)isUnique;
-(int)techCount;
-(int)weaponCount;
-(int)crewCount;
@end
