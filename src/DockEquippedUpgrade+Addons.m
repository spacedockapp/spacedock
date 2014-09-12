#import "DockEquippedUpgrade+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade.h"
#import "DockSet+Addons.h"
#import "DockSetItem+Addons.h"
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

-(void)willSave
{
    [self.equippedShip.squad updateModificationDate];
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

-(BOOL)isCaptain
{
    return self.upgrade.isCaptain;
}

-(NSString*)plainDescription
{
    return self.upgrade.plainDescription;
}

-(NSString*)descriptionForBuildSheet
{
    DockCaptain* captain = self.equippedShip.captain;
    if ([captain isKirk]) {
        DockUpgrade* upgrade = self.upgrade;
        if (upgrade.isFederation && upgrade.isTalent) {
            return @"Federation Elite Talent";
        }
    } else if ([captain.special isEqualToString: @"AddsHiddenTechSlot"]) {
        DockEquippedUpgrade* most = [self.equippedShip mostExpensiveUpgradeOfFaction: nil upType: @"Tech"];

        if (most.upgrade == self.upgrade) {
            return @"Tech Upgrade";
        }
    }
    return [NSString stringWithFormat: @"%@ [%@]", self.upgrade.title, self.upgrade.setCode];
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
    return [upgrade costForShip: equippedShip equippedUpgade: self];
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

-(NSString*)asPlainTextFormat
{
    DockUpgrade* upgrade = self.upgrade;
    NSString* s = nil;
    if ([self costIsOverridden]) {
        s = [NSString stringWithFormat: @"%@ [%@] (%d overridden to %d)\n", upgrade.titleForPlainTextFormat, upgrade.setCode, [self nonOverriddenCost], [self cost]];
    } else {
        s = [NSString stringWithFormat: @"%@ [%@] (%d)\n", upgrade.titleForPlainTextFormat, upgrade.setCode, [self cost]];
    }
    return s;
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
    json[@"calculatedCost"] = [NSNumber numberWithInt: self.nonOverriddenCost];
    if ([self costIsOverridden]) {
        [json setObject: @YES forKey: @"costIsOverridden"];
        [json setObject: self.overriddenCost forKey: @"overriddenCost"];
    }
    
    return [NSDictionary dictionaryWithDictionary: json];
}

-(int)additionalWeaponSlots
{
    return self.upgrade.additionalWeaponSlots;
}

-(int)additionalTechSlots
{
    return self.upgrade.additionalTechSlots;
}

-(int)additionalCrewSlots
{
    return self.upgrade.additionalCrewSlots;
}

-(int)additionalTalentSlots
{
    return self.upgrade.additionalTalentSlots;
}

@end
