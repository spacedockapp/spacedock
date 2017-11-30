//
//  DockResourceUpgrade+Addons.h
//  Space Dock
//
//  Created by Robert George on 11/29/17.
//  Copyright © 2017 Robert George. All rights reserved.
//

#import "DockResourceUpgrade.h"

@interface DockResourceUpgrade (Addons)
+(DockResourceUpgrade*)resourceUpgradeForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
@end
