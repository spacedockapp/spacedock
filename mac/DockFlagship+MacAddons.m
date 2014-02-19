//
//  DockFlagship+MacAddons.m
//  Space Dock
//
//  Created by Rob Tsuk on 2/19/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import "DockFlagship+MacAddons.h"

#import "DockUtils.h"

@implementation DockFlagship (MacAddons)

-(NSAttributedString*)styledAttack
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    
    int v = [self.attack intValue];
    if (v > 0) {
        [desc appendAttributedString: makeCentered(coloredString([self.attack stringValue], [NSColor whiteColor], [NSColor redColor]))];
    }
    
    return desc;
}

-(NSAttributedString*)styledAgility
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    int v = [self.agility intValue];
    if (v > 0) {
        [desc appendAttributedString: makeCentered(coloredString([self.agility stringValue], [NSColor blackColor], [NSColor greenColor]))];
    }
    return desc;
}

-(NSAttributedString*)styledHull
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    int v = [self.hull intValue];
    if (v > 0) {
        [desc appendAttributedString: makeCentered(coloredString([self.hull stringValue], [NSColor blackColor], [NSColor yellowColor]))];
    }
    return desc;
}

-(NSAttributedString*)styledShield
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    int v = [self.shield intValue];
    if (v > 0) {
        [desc appendAttributedString: makeCentered(coloredString([self.shield stringValue], [NSColor whiteColor], [NSColor blueColor]))];
    }
    return desc;
}

@end
