//
//  DockShip+Addons.m
//  Space Dock
//
//  Created by Rob Tsuk on 9/27/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockShip+Addons.h"

#import "DockUtils.h"

@implementation DockShip (Addons)

+(DockShip*)shipForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Ship" inManagedObjectContext: context];
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

-(NSString*)description
{
    if ([[self title] isEqualToString: self.shipClass]) {
        return self.title;
    }

    return [NSString stringWithFormat: @"%@ (%@)", self.title, self.shipClass];
}

-(NSAttributedString*)styledDescription
{
    NSAttributedString* space = [[NSAttributedString alloc] initWithString: @" "];
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: [self description]];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.attack stringValue], [NSColor whiteColor], [NSColor redColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.agility stringValue], [NSColor blackColor], [NSColor greenColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.hull stringValue], [NSColor blackColor], [NSColor yellowColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.shield stringValue], [NSColor whiteColor], [NSColor blueColor])];
    return desc;
}

-(BOOL)isBreen
{
    NSRange r = [self.shipClass rangeOfString: @"Breen"];
    return r.location != NSNotFound;
}

-(BOOL)isJemhadar
{
    NSRange r = [self.shipClass rangeOfString: @"Jem'hadar"];
    return r.location != NSNotFound;
}

-(BOOL)isDefiant
{
    return [self.title isEqualToString: @"U.S.S. Defiant"];
}

-(BOOL)isUnique
{
    return [self.unique boolValue];
}

-(BOOL)isFederation
{
    return [self.faction isEqualToString: @"Federation"];
}

-(BOOL)isBajoran
{
    return [self.faction isEqualToString: @"Bajoran"];
}

-(int)techCount
{
    return [self.tech intValue];
}

-(int)weaponCount
{
    return [self.weapon intValue];
}

-(int)crewCount
{
    return [self.crew intValue];
}

@end
