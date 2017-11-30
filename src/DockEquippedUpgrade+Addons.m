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
    } else if ([captain.externalId isEqualToString: @"tahna_los_op6prize"]) {
        if ([self.specialTag isEqualToString:@"TahnaLosTech"]) {
            return @"Tech Upgrade";
        }
    } else if ([self.equippedShip containsUpgradeWithId:@"shinzon_romulan_talents_71533"] != nil) {
        if ( [self.upgrade isTalent] && [self.upgrade.faction isEqualToString:@"Romulan"] && [self.specialTag hasPrefix:@"shinzon_ET_"]) {
            return @"Romulan Elite Talent";
        }
    } else if ([self.equippedShip containsUpgradeWithId:@"dna_encoded_message_72938"] != nil) {
            if ( [self.upgrade isTalent] && [self.upgrade.faction isEqualToString:@"Klingon"] && [self.specialTag hasPrefix:@"dna-enc_ET_"]) {
                return @"Klingon Elite Talent";
            }
    } else if ([self.equippedShip containsUpgradeWithId:@"quark_71786"]) {
        if ( [self.upgrade isTech] && [self.specialTag isEqualToString:@"QuarkTech"] ) {
            return @"Tech Upgrade";
        }
    } else if ([self.equippedShip containsUpgradeWithId:@"quark_weapon_71786"]) {
        if ( [self.upgrade isWeapon] && [self.specialTag isEqualToString:@"QuarkWeapon"] ) {
            return @"Weapon Upgrade";
        }
    } else if ([self.equippedShip containsUpgradeWithId:@"triphasic_emitter_71536"]) {
        if ( [self.upgrade isWeapon] && [self.specialTag hasPrefix:@"HiddenWeapon"] ) {
            return @"Weapon Upgrade";
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
    if (!self.upgrade.isPlaceholder && !other.isPlaceholder) {
        if ([self.upgrade.upType isEqualToString:other.upgrade.upType]) {
            if (self.upgrade.isTalent) {
                if ([self.upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"]) {
                    return NSOrderedAscending;
                } else if ([other.upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"]) {
                    return NSOrderedDescending;
                }
            }
            if (self.specialTag != nil) {
                if (other.specialTag != nil) {
                    return [self.specialTag compare:other.specialTag];
                } else {
                    return NSOrderedAscending;
                }
            } else if (![other.specialTag isEqualToString:@""]) {
                return NSOrderedDescending;
            }
        }
    }
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

-(int)additionalBorgSlots
{
    return self.upgrade.additionalBorgSlots;
}

-(int)additionalTalentSlots
{
    return self.upgrade.additionalTalentSlots;
}

@end
