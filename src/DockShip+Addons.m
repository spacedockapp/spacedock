//
//  DockShip+Addons.m
//  Space Dock
//
//  Created by Rob Tsuk on 9/27/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockShip+Addons.h"

@implementation DockShip (Addons)

-(NSString*)description
{
    if ([[self title] isEqualToString: self.shipClass]) {
        return self.title;
    }

    return [NSString stringWithFormat: @"%@ (%@)", self.title, self.shipClass];
}

-(BOOL)isBreen
{
    NSRange r = [self.shipClass rangeOfString: @"Breen"];
    return r.location != NSNotFound;
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
