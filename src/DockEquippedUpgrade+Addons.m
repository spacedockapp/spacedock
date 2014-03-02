#import "DockEquippedUpgrade+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"

@implementation DockEquippedUpgrade (Addons)

+(NSSet*)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects: @"overridden", @"overriddenCost", nil];
}

+(NSSet*)keyPathsForValuesAffectingFormattedCost
{
    return [NSSet setWithObjects: @"cost", nil];
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

-(NSString*)descriptionForBuildSheet
{
    if ([self.equippedShip.captain isKirk]) {
        DockUpgrade* upgrade = self.upgrade;
        if (upgrade.isFederation && upgrade.isTalent) {
            return @"Federation Elite Talent";
        }
    }
    return self.upgrade.title;
}

-(NSArray*)sortedUpgrades
{
    return nil;
}

-(NSArray*)sortedUpgradesWithFlagship
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

-(BOOL)costIsOverridden
{
    return [self.overridden boolValue];
}

-(void)removeCostOverride
{
    if (self.costIsOverridden) {
        self.overridden = [NSNumber numberWithBool: NO];
    }
}

-(void)overrideWithCost:(int)cost
{
    self.overriddenCost = [NSNumber numberWithInt: cost];
    self.overridden = [NSNumber numberWithBool: YES];
}

-(NSDictionary*)asJSON
{
    NSMutableDictionary* json = [NSMutableDictionary dictionaryWithCapacity: 0];
    
    json[@"upgradeId"] = self.upgrade.externalId;
    json[@"upgradeTitle"] = self.upgrade.title;
    if ([self costIsOverridden]) {
        [json setObject: @YES forKey: @"costIsOverridden"];
        [json setObject: self.overriddenCost forKey: @"overriddenCost"];
    }
    
    return [NSDictionary dictionaryWithDictionary: json];
}

@end
