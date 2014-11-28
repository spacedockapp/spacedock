//
//  DockSquadronUpgrade+Addons.m
//  Space Dock
//
//  Created by Robert George on 11/20/14.
//  Copyright (c) 2014 Robert George. All rights reserved.
//

#import "DockSquadronUpgrade+Addons.h"

@implementation DockSquadronUpgrade (Addons)

+(DockSquadronUpgrade*)squadronUpgradeForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Squadron" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"externalId == %@", externalId];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];
    
    if (existingItems.count > 0) {
        return existingItems[0];
    }
    
    return nil;
}

@end
