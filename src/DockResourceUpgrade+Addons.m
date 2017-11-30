//
//  DockResourceUpgrade+Addons.m
//  Space Dock
//
//  Created by Robert George on 11/29/17.
//  Copyright © 2017 Robert George. All rights reserved.
//

#import "DockResourceUpgrade+Addons.h"

@implementation DockResourceUpgrade (Addons)

+(DockResourceUpgrade*)resourceUpgradeForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"ResourceUpgrade" inManagedObjectContext: context];
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
