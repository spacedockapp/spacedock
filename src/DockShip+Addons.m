//
//  DockShip+Addons.m
//  Space Dock
//
//  Created by Rob Tsuk on 9/27/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockShip+Addons.h"

@implementation DockShip (Addons)

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
