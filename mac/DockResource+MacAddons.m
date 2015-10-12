//
//  DockResource+MacAddons.m
//  Space Dock
//
//  Created by Robert George on 2/19/15.
//  Copyright (c) 2015 Robert George. All rights reserved.
//

#import "DockEquippedShip+MacAddons.h"
#import "DockResource+MacAddons.h"
#import "DockResource+Addons.h"
#import "DockSet+Addons.h"
#import "DockSquad+Addons.h"

extern NSString* kMarkExpiredResources;

@implementation DockResource (MacAddons)
-(NSAttributedString*)styledTitle
{
    NSMutableAttributedString* title = [[NSMutableAttributedString alloc] initWithString:self.title];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL markExp = [defaults boolForKey:kMarkExpiredResources];
    if (!markExp) {
        return title;
    }
    DockSet* set = [self.sets anyObject];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:set.releaseDate];
    [components setDay:1];

    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSMonthCalendarUnit
                                       fromDate:[cal dateFromComponents:components]
                                       toDate:[NSDate date] options:0];
    if (ageComponents.month >= 18) {
        NSMutableAttributedString* exp = [[NSMutableAttributedString alloc] initWithString:@" (Retired)"];
        [exp addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,[exp length])];
        [title appendAttributedString:exp];
    } else if (ageComponents.month == 17) {
        NSMutableAttributedString* exp = [[NSMutableAttributedString alloc] initWithString:@" (Retiring)"];
        [exp addAttribute:NSForegroundColorAttributeName value:[NSColor orangeColor] range:NSMakeRange(0,[exp length])];
        [title appendAttributedString:exp];
    }
    
    return title;
}
-(NSNumber*)costForSquad
{
    DockSquad* squad = [DockEquippedShip currentTargetShip].squad;
    return [self costForSquad:squad];
}
@end