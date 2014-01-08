#import "DockEquippedUpgrade+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade.h"
#import "DockShip+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockEquippedUpgrade (Addons)

+(NSSet*)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects: @"overridden", @"overriddenCost", nil];
}

-(NSString*)title
{
    return self.upgrade.title;
}

-(NSString*)faction
{
    return self.upgrade.faction;
}

-(BOOL)isPlaceholder
{
    return self.upgrade.isPlaceholder;
}

-(NSString*)plainDescription
{
    return self.upgrade.plainDescription;
}

-(NSAttributedString*)styledDescription
{
    return self.upgrade.styledDescription;
}

-(NSArray*)sortedUpgrades
{
    return nil;
}

-(NSArray*)upgrades
{
    return nil;
}

-(int)baseCost
{
    DockUpgrade* upgrade = self.upgrade;

    if ([upgrade isPlaceholder]) {
        return 0;
    }

    return [upgrade.cost intValue];
}

-(int)nonOverriddenCost
{
    DockEquippedShip* equippedShip = self.equippedShip;
    DockUpgrade* upgrade = self.upgrade;
    return [upgrade costForShip: equippedShip];
}

-(int)cost
{
    if ([self.overridden boolValue]) {
        return [self.overriddenCost intValue];
    }
    
    return [self nonOverriddenCost];
}

-(int)rawCost
{
    return [self.upgrade.cost intValue];
}

-(NSComparisonResult)compareTo:(DockEquippedUpgrade*)other
{

    return [[self upgrade] compareTo: [other upgrade]];
}

-(NSString*)ability
{
    return self.upgrade.ability;
}

-(NSString*)typeCode
{
    return self.upgrade.typeCode;
}

@end
