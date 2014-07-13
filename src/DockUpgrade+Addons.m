#import "DockUpgrade+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockCrew.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockResource.h"
#import "DockShip+Addons.h"
#import "DockTalent.h"
#import "DockTech.h"
#import "DockUtils.h"
#import "DockWeapon.h"

@implementation DockUpgrade (Addons)

+(NSSet*)allFactions:(NSManagedObjectContext*)context
{
    NSMutableSet* allFactionsSet = [[NSMutableSet alloc] initWithCapacity: 0];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Upgrade" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        for (DockUpgrade* upgrade in existingItems) {
            [allFactionsSet addObject: upgrade.faction];
        }
        return [NSSet setWithSet: allFactionsSet];
    }

    return nil;
}

+(DockUpgrade*)upgradeForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Upgrade" inManagedObjectContext: context];
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

+(DockUpgrade*)placeholder:(NSString*)upType inContext:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: upType inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"placeholder = YES"];
    [request setPredicate: predicateTemplate];
    DockUpgrade* placeholderUpgrade = nil;
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count == 0) {
        Class upClass = [DockUpgrade class];

        if ([upType isEqualToString: @"Weapon"]) {
            upClass = [DockWeapon class];
        } else if ([upType isEqualToString: @"Tech"]) {
            upClass = [DockTech class];
        } else if ([upType isEqualToString: @"Talent"]) {
            upClass = [DockTalent class];
        } else if ([upType isEqualToString: @"Captain"]) {
            upClass = [DockCaptain class];
        } else if ([upType isEqualToString: @"Crew"]) {
            upClass = [DockCrew class];
        } else if ([upType isEqualToString: @"Borg"]) {
            upClass = [DockUpgrade class];
        }

        placeholderUpgrade = [[upClass alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
        placeholderUpgrade.title = upType;
        placeholderUpgrade.upType = upType;
        placeholderUpgrade.placeholder = @YES;
    } else {
        placeholderUpgrade = existingItems[0];
    }

    return placeholderUpgrade;
}

+(NSArray*)findUpgrades:(NSString*)title context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Upgrade" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"title like %@", title];
    [request setPredicate: predicateTemplate];
    NSError* err;
    return [context executeFetchRequest: request error: &err];
}

-(NSString*)plainDescription
{
    if ([self isPlaceholder]) {
        return self.title;
    }

    return [NSString stringWithFormat: @"%@ (%@)", self.title, self.upType];
}

-(BOOL)isTalent
{
    return [self.upType isEqualToString: @"Talent"];
}

-(BOOL)isCrew
{
    return [self.upType isEqualToString: @"Crew"];
}

-(BOOL)isWeapon
{
    return [self.upType isEqualToString: @"Weapon"];
}

-(BOOL)isCaptain
{
    return [self.upType isEqualToString: @"Captain"];
}

-(BOOL)isAdmiral
{
    return [self.upType isEqualToString: @"Admiral"];
}

-(BOOL)isTech
{
    return [self.upType isEqualToString: @"Tech"];
}

-(BOOL)isBorg
{
    return [self.upType isEqualToString: @"Borg"];
}

-(BOOL)isPlaceholder
{
    return [[self placeholder] boolValue];
}

-(BOOL)isUnique
{
    return [[self unique] boolValue];
}

-(BOOL)isDominion
{
    return [self.faction isEqualToString: @"Dominion"];
}

-(BOOL)isKlingon
{
    return [self.faction isEqualToString: @"Klingon"];
}

-(BOOL)isBajoran
{
    return [self.faction isEqualToString: @"Bajoran"];
}

-(BOOL)isFederation
{
    return [self.faction isEqualToString: @"Federation"];
}

-(BOOL)isVulcan
{
    return [self.faction isEqualToString: @"Vulcan"];
}

-(BOOL)isFactionBorg
{
    return [self.faction isEqualToString: @"Borg"];
}

-(BOOL)isRestrictedOnlyByFaction
{
    NSString* upgradeId = self.externalId;

    if ([upgradeId isEqualToString: @"tholian_punctuality_opwebprize"] || [upgradeId isEqualToString: @"first_strike_3rd_wing_attack_ship"]) {
        return NO;
    }
    return YES;
}

-(NSComparisonResult)compareTo:(DockUpgrade*)other
{
    NSString* upTypeMe = [self upSortType];
    NSString* upTypeOther = [other upSortType];
    NSComparisonResult r = [upTypeMe compare: upTypeOther];

    if (r == NSOrderedSame) {
        BOOL selfIsPlaceholder = [self isPlaceholder];
        BOOL otherIsPlaceholder = [other isPlaceholder];

        if (selfIsPlaceholder == otherIsPlaceholder) {
            return [self.title caseInsensitiveCompare: other.title];
        }

        if (selfIsPlaceholder) {
            return NSOrderedDescending;
        }

        return NSOrderedAscending;
    }

    if ([upTypeMe isEqualToString: @"Captain"]) {
        return NSOrderedAscending;
    }

    if ([upTypeOther isEqualToString: @"Captain"]) {
        return NSOrderedDescending;
    }

    return r;
}

-(int)limitForShip:(DockEquippedShip*)targetShip
{
    if ([self isCaptain]) {
        return [targetShip captainCount];
    }

    if ([self isAdmiral]) {
        return [targetShip admiralCount];
    }

    if ([self isTalent]) {
        return [targetShip talentCount];
    }


    if (![targetShip isResourceSideboard]) {

        NSString* targetShipClass = self.targetShipClass;

        if (targetShipClass != nil) {
            NSString* shipClass = targetShip.ship.shipClass;

            if (![shipClass isEqualToString: targetShipClass]) {
                return 0;
            }
        }
    }

    if ([self isWeapon]) {
        return [targetShip weaponCount];
    }

    if ([self isCrew]) {
        return [targetShip crewCount];
    }

    if ([self isTech]) {
        return [targetShip techCount];
    }

    if ([self isBorg]) {
        return [targetShip borgCount];
    }

    return 0;
}

-(NSString*)targetShipClass
{
    NSString* special = self.special;

    if ([special isEqualToString: @"OnlyForRomulanScienceVessel"]) {
        return @"Romulan Science Vessel";
    } else if ([special isEqualToString: @"OnlyForRaptorClassShips"]) {
        return @"Raptor Class";
    } else if ([special isEqualToString: @"combat_vessel_variant_71508"]) {
        return @"Suurok Class";
    }

    return nil;
}

-(NSString*)upSortType
{
    if ([self isAdmiral]) {
        return @"AAAAAdmiral";
    }

    if ([self isCaptain]) {
        return @"AAACaptain";
    }

    if ([self isTalent]) {
        return @"AATalent";
    }

    return self.upType;
}

-(NSString*)sortStringForSet
{
    return [NSString stringWithFormat: @"%@:c:%@:%@", self.faction, self.upSortType, self.title];
}

-(NSString*)itemDescription
{
    return [NSString stringWithFormat: @"%@: %@", self.typeCode, self.title];
}

-(NSString*)typeCode
{
    if ([self isWeapon]) {
        return @"W";
    }

    if ([self isCrew]) {
        return @"C";
    }

    if ([self isTech]) {
        return @"T";
    }

    if ([self isTalent]) {
        return @"E";
    }

    if ([self isCaptain]) {
        return @"Cp";
    }

    if ([self isAdmiral]) {
        return @"A";
    }

    if ([self isBorg]) {
        return @"B";
    }

    return @"?";

}

-(NSString*)optionalAttack
{
    if ([self isWeapon]) {
        id attackValue = [self valueForKey: @"attack"];

        if ([attackValue intValue] > 0) {
            return attackValue;
        }
    }

    return nil;
}

-(NSString*)optionalRange
{
    if ([self isWeapon]) {
        id rangeValue = [self valueForKey: @"range"];

        if ([rangeValue length] > 0) {
            return rangeValue;
        }
    }

    return nil;
}

-(int)costForShip:(DockEquippedShip*)equippedShip
{
    return [self costForShip: equippedShip equippedUpgade: nil];
}

-(int)costForShip:(DockEquippedShip*)equippedShip equippedUpgade:(DockEquippedUpgrade*)equippedUpgrade
{
    DockUpgrade* upgrade = self;

    if ([upgrade isPlaceholder]) {
        return 0;
    }

    int originalCost = [upgrade.cost intValue];
    int cost = originalCost;

    DockShip* ship = equippedShip.ship;
    DockCaptain* captain = equippedShip.captain;
    BOOL isSideboard = [equippedShip isResourceSideboard];

    if ([upgrade isCaptain]) {
        captain = (DockCaptain*)upgrade;

        if ([captain isZeroCost]) {
            return 0;
        }
    }

    NSString* captainSpecial = captain.special;
    NSString* upgradeSpecial = upgrade.special;

    if ([upgrade isTalent]) {
        if ([captainSpecial isEqualToString: @"BaselineTalentCostToThree"] && self.isFederation && !isSideboard) {
            cost = 3;
        }
    } else if ([upgrade isCrew]) {
        if (([captainSpecial isEqualToString: @"CrewUpgradesCostOneLess"] || [captainSpecial isEqualToString: @"hugh_71522"] ) && !isSideboard) {
            cost -= 1;
        }

        if ([upgradeSpecial isEqualToString: @"costincreasedifnotromulansciencevessel"]) {
            if (![ship isRomulanScienceVessel]) {
                cost += 5;
            }
        }
    } else if ([upgrade isWeapon]) {
        if ([captainSpecial isEqualToString: @"WeaponUpgradesCostOneLess"]) {
            cost -= 1;
        }
    }

    if ([upgradeSpecial isEqualToString: @"costincreasedifnotbreen"]) {
        if (![ship isBreen]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PenaltyOnShipOtherThanDefiant"]) {
        if (![ship isDefiant]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PlusFivePointsNonJemHadarShips"]) {
        if (![ship isJemhadar]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PenaltyOnShipOtherThanKeldonClass"]) {
        if (![ship isKeldon]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PlusFiveOnNonSpecies8472"]) {
        if (![ship isSpecies8472]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PlusFiveForNonKazon"]) {
        if (![ship isKazon]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PlusFiveIfNotBorgShip"]) {
        if (![ship isBorg]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PhaserStrike"] || [upgradeSpecial isEqualToString: @"CostPlusFiveExceptBajoranInterceptor"]) {
        if (![ship isBajoranInterceptor]) {
            cost += 5;
        }
    }

    if ([captainSpecial isEqualToString: @"OneDominionUpgradeCostsMinusTwo"] && !isSideboard) {
        if ([upgrade isDominion]) {
            DockEquippedUpgrade* most = [equippedShip mostExpensiveUpgradeOfFaction: @"Dominion" upType: nil];

            if (most.upgrade == self && (equippedUpgrade == nil || equippedUpgrade == most)) {
                cost -= 2;
            }
        }
    } else if ([captainSpecial isEqualToString: @"VulcanAndFedTechUpgradesMinus2"] && !isSideboard) {
        if ([upgrade isTech] && ([upgrade isFederation] || [upgrade isVulcan])) {
            cost -= 2;
        }
    } else if ([captainSpecial isEqualToString: @"AddTwoCrewSlotsDominionCostBonus"] && !isSideboard) {
        if ([upgrade isDominion]) {
            NSArray* all = [equippedShip allUpgradesOfFaction: @"Dominion" upType: @"Crew"];
            
            id upgradeCheck = ^(id obj, NSUInteger idx, BOOL* stop) {
                DockEquippedUpgrade* eu = obj;
                DockUpgrade* upgradeToTest = eu.upgrade;
                return (upgradeToTest == self && (equippedUpgrade == nil || equippedUpgrade == eu));
            };
            NSInteger position = [all indexOfObjectPassingTest: upgradeCheck];

            if (position != NSNotFound && position < 2) {
                cost -= 1;
            }
        }
    } else if ([captainSpecial isEqualToString: @"AddsHiddenTechSlot"] && !isSideboard) {
        NSArray* allTech = [equippedShip allUpgradesOfFaction: nil upType: @"Tech"];
        NSSet* ineligibleTechUpgrades = [NSSet setWithArray: @[
                                                               @"OnlyVoyager",
                                                               @"OnlySpecies8472Ship",
                                                               @"PenaltyOnShipOtherThanDefiant",
                                                               @"PenaltyOnShipOtherThanKeldonClass",
                                                               @"OnlySpecies8472Ship",
                                                               @"CostPlusFiveExceptBajoranInterceptor",
                                                               @"PlusFiveForNonKazon",
                                                               @"OnlyForRomulanScienceVessel",
                                                               @"OnlyForRaptorClassShips",
                                                               @"OnlyJemHadarShips",
                                                               @"OnlyForRaptorClassShips"
                                                               ]];
        DockEquippedUpgrade* most = nil;

        for (DockEquippedUpgrade* eu in allTech) {
            NSString* techSpecial = eu.upgrade.special;
            if (techSpecial == nil || ![ineligibleTechUpgrades containsObject: techSpecial]) {
                most = eu;
                break;
            }
        }
        
        if (most.upgrade == self) {
            cost = 3;
        }
    }

    if (!factionsMatch(ship, self) && !equippedShip.isResourceSideboard && !factionsMatch(self, equippedShip.flagship)) {
        if ([captainSpecial isEqualToString: @"UpgradesIgnoreFactionPenalty"] && ![upgrade isCaptain]) {
        } else if ([captainSpecial isEqualToString: @"NoPenaltyOnFederationOrBajoranShip"]  && [upgrade isCaptain]) {
            if (!([ship isFederation] || [ship isBajoran])) {
                cost += 1;
            }
        } else if ([captainSpecial isEqualToString: @"CaptainAndTalentsIgnoreFactionPenalty"] &&
                   ([upgrade isTalent] || [upgrade isCaptain])) {
        } else if ([captainSpecial isEqualToString: @"hugh_71522"] &&
                   [upgrade isFactionBorg]) {
        } else if ([captainSpecial isEqualToString: @"lore_71522"] &&
                   [upgrade isTalent]) {
        } else {
            if (upgrade.isAdmiral) {
                cost += 3;
            } else {
                cost += 1;
            }
        }

    }

    if ([[upgrade externalId] isEqualToString: @"borg_ablative_hull_armor_71283"]) {
        if ([[ship externalId] isEqualToString: @"tactical_cube_138_71444"]) {
            cost = 7;
        }
    }

    if ([upgrade isWeapon] && [equippedShip containsUpgradeWithId: @"sakonna_gavroche"] != nil) {
        if (cost <= 5) {
            cost -= 2;
        }
    }


    if (cost < 0) {
        cost = 0;
    }
    
    return cost;
}

-(int)additionalWeaponSlots
{
    NSString* special = self.special;

    if ([special isEqualToString: @"AddTwoWeaponSlots"]) {
        return 2;
    }
    if ([special isEqualToString: @"AddsOneWeaponOneTech"]) {
        return 1;
    }
    if ([special isEqualToString: @"sakonna_gavroche"]) {
        return 1;
    }
    return 0;
}

-(int)additionalTechSlots
{
    if ([self.special isEqualToString: @"AddsOneWeaponOneTech"]) {
        return 1;
    }
    if ([self.externalId isEqualToString: @"vulcan_high_command_2_0_71446"]) {
        return 2;
    }
    if ([self.externalId isEqualToString: @"vulcan_high_command_1_1_71446"]) {
        return 1;
    }
    return 0;
}

-(int)additionalCrewSlots
{
    NSString* externalId = self.externalId;

    if ([externalId isEqualToString: @"vulcan_high_command_0_2_71446"]) {
        return 2;
    }
    if ([externalId isEqualToString: @"vulcan_high_command_1_1_71446"]) {
        return 1;
    }
    return 0;
}

-(int)additionalHull
{
    if ([self.externalId isEqualToString: @"combat_vessel_variant_71508"]) {
        return 1;
    }
    return 0;
}

-(int)additionalAttack
{
    if ([self.externalId isEqualToString: @"combat_vessel_variant_71508"]) {
        return 1;
    }
    return 0;
}

-(NSString*)weaponRange
{
    return nil;
}

-(NSString*)rangeAsString
{
    return nil;
}

-(NSString*)combinedFactions
{
    return combinedFactionString(self);
}


@end
