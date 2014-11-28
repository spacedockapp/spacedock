//
//  DockSquadronUpgrade+Addons.h
//  Space Dock
//
//  Created by Robert George on 11/20/14.
//  Copyright (c) 2014 Robert George. All rights reserved.
//

#import "DockSquadronUpgrade.h"

@interface DockSquadronUpgrade (Addons)
+(DockSquadronUpgrade*)squadronUpgradeForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
@end
