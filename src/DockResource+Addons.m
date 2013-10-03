//
//  DockResource+Addons.m
//  Space Dock
//
//  Created by Rob Tsuk on 10/3/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockResource+Addons.h"

@implementation DockResource (Addons)

+(DockResource*)resourceForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Resource" inManagedObjectContext: context];
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
