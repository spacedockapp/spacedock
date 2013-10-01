//
//  DockCaptain+Addons.m
//  Space Dock
//
//  Created by Rob Tsuk on 9/28/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockCaptain+Addons.h"

@implementation DockCaptain (Addons)

-(int)talentCount
{
    return [self.talent intValue];
}

+(DockUpgrade*)zeroCostCaptain:(NSString*)faction context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Captain" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"cost = 0 and faction like %@", faction];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];
    if (existingItems.count > 0) {
        return existingItems[0];
    }
    return nil;
}

@end
