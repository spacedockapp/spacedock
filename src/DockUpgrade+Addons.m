#import "DockUpgrade+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockConstants.h"
#import "DockCrew.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockFleetCaptain+Addons.h"
#import "DockResource.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockTalent.h"
#import "DockTech.h"
#import "DockUtils.h"
#import "DockWeapon.h"
#import "DockSquadronUpgrade.h"
#import "DockBorg.h"
#import "DockResourceUpgrade.h"

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
            if (![upgrade.faction isEqualToString:@""]) {
                [allFactionsSet addObject: upgrade.faction];
            }
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
    NSString* entityName = upType;
    if ([upType isEqualToString:@"Resource"]) {
        entityName = @"ResourceUpgrade";
    }
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: context];
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
            upClass = [DockBorg class];
        } else if ([upType isEqualToString: @"Squadron"]) {
            upClass = [DockSquadronUpgrade class];
        } else if ([upType isEqualToString: @"Resource"]) {
            upClass = [DockResourceUpgrade class];
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

static NSDictionary* sItemLabels = nil;

-(NSString*)disambiguatedTitle
{
    NSString* externalId = self.externalId;

    if (sItemLabels == nil) {
        sItemLabels = @{
            @"quark_71786": @"Tech",
            @"quark_weapon_71786": @"Weapon",
            @"vulcan_high_command_2_0_71446": @"2/0",
            @"vulcan_high_command_1_1_71446": @"1/1",
            @"vulcan_high_command_0_2_71446": @"0/2",
            @"calvin_hudson_71528": @"Crew",
            @"calvin_hudson_b_71528": @"Tech",
            @"calvin_hudson_c_71528": @"Weapon",
            @"chakotay_71528": @"Crew",
            @"chakotay_b_71528": @"Weapon",
            @"jean_luc_picard_71531": @"Talent",
            @"jean_luc_picard_b_71531": @"Tech",
            @"jean_luc_picard_c_71531": @"Weapon",
            @"jean_luc_picard_d_71531": @"Crew",
            @"cargo_hold_20_72013": @"2/0",
            @"cargo_hold_11_72013": @"1/1",
            @"cargo_hold_02_72013": @"0/2",
        };
    }

    NSString* label = sItemLabels[externalId];
    NSString* title = self.title;
    if (label == nil) {
        return title;
    }

    return [NSString stringWithFormat: @"%@ (%@)", title, label];
}

-(NSString*)titleForPlainTextFormat
{
    return self.title;
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

-(BOOL)isQMark
{
    if ([self.externalId isEqualToString:@"systems_upgrade_w_71998p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"assault_vessel_upgrade_w_71803"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"aft_torpedo_launcher_w_72011"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"systems_upgrade_c_71998p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"assault_vessel_upgrade_c_71803"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"aft_torpedo_launcher_c_72011"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"systems_upgrade_71998p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"assault_vessel_upgrade_t_71803"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"aft_torpedo_launcher_t_72011"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"temporal_observatory_c_72005g"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"temporal_observatory_t_72005g"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"temporal_observatory_w_72005g"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"maintenance_crew_c_72022"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"maintenance_crew_t_72022"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"maintenance_crew_w_72022"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"auxiliary_control_room_t_72316p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"auxiliary_control_room_w_72316p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"automated_distress_beacon_c_72316p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"automated_distress_beacon_t_72316p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"automated_distress_beacon_w_72316p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"computer_core_c_72336"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"computer_core_w_72336"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"delta_shift_c_72320p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"delta_shift_t_72320p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"delta_shift_w_72320p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"delta_shift_e_72320p"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"borg_support_vehicle_token_c_72006"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"borg_support_vehicle_token_t_72006"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"borg_support_vehicle_token_w_72006"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"borg_support_vehicle_token_e_72006"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"borg_support_vehicle_token_72006"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"captured_c_72937"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"captured_t_72937"]) {
        return YES;
    }
    if ([self.externalId isEqualToString:@"captured_w_72937"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isCaptain
{
    return [self.upType isEqualToString: @"Captain"];
}

-(BOOL)isAdmiral
{
    return [self.upType isEqualToString: kAdmiralUpgradeType];
}

-(BOOL)isFleetCaptain
{
    return [self.upType isEqualToString: kFleetCaptainUpgradeType];
}

-(BOOL)isOfficer
{
    return [self.upType isEqualToString: kOfficerUpgradeType];
}

-(BOOL)isTech
{
    return [self.upType isEqualToString: @"Tech"];
}

-(BOOL)isBorg
{
    return [self.upType isEqualToString: @"Borg"];
}

-(BOOL)isSquadron
{
    return [self.upType isEqualToString:@"Squadron"];
}

-(BOOL)isResourceUpgrade
{
    return [self.upType isEqualToString:@"Resource"];
}


-(BOOL)isPlaceholder
{
    return [[self placeholder] boolValue];
}

-(BOOL)isUnique
{
    return [[self unique] boolValue];
}

-(BOOL)isMirrorUniverseUnique
{
    return [[self mirrorUniverseUnique] boolValue];
}

-(BOOL)isDominion
{
    return targetHasFaction(@"Dominion", self);
}

-(BOOL)isKlingon
{
    return targetHasFaction(@"Klingon", self);
}

-(BOOL)isKazon
{
    return targetHasFaction(@"Kazon", self);
}

-(BOOL)isBajoran
{
    return targetHasFaction(@"Bajoran", self);
}

-(BOOL)isFederation
{
    if (targetHasFaction(@"Vulcan",self) || targetHasFaction(@"Bajoran",self)) {
        return YES;
    }
    return targetHasFaction(@"Federation", self);
}

-(BOOL)isFerengi
{
    return targetHasFaction(@"Ferengi", self);
}

-(BOOL)isVulcan
{
    return targetHasFaction(@"Vulcan", self);
}

-(BOOL)isFactionBorg
{
    return targetHasFaction(@"Borg", self);
}

-(BOOL)isRomulan
{
    return targetHasFaction(@"Romulan", self);
}

-(BOOL)isQContinuum
{
    return targetHasFaction(@"Q Continuum", self);
}
-(BOOL)isXindi
{
    return targetHasFaction(@"Xindi", self);
}

-(BOOL)isRestrictedOnlyByFaction
{
    NSString* upgradeId = self.externalId;

    if ([upgradeId isEqualToString: @"tholian_punctuality_opwebprize"] || [upgradeId isEqualToString: @"first_strike_3rd_wing_attack_ship"]) {
        return NO;
    }
    return YES;
}

-(BOOL)isIndependent
{
    if (targetHasFaction(@"Ferengi",self) || targetHasFaction(@"Kazon",self) || targetHasFaction(@"Xindi",self)) {
        return YES;
    }
    return targetHasFaction(@"Independent", self);
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

    if ([self isFleetCaptain]) {
        return [targetShip fleetCaptainCount];
    }

    if ([self isOfficer]) {
        return [targetShip officerLimit];
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
    
    if ([self isSquadron]) {
        return [targetShip squadronUpgradeCount];
    }
    
    if ([self isResourceUpgrade]) {
        return [targetShip resourceUpgradeCount];
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
        return @"AAAAAAdmiral";
    }

    if ([self isFleetCaptain]) {
        return @"AAAACaptain";
    }

    if ([self isCaptain]) {
        return @"AAAAAAAACaptain";
    }

    if ([self isTalent]) {
        return @"AATalent";
    }
    if ([self isResourceUpgrade]) {
        return @"ZZZZZResource";
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

    if ([self isOfficer]) {
        return @"O";
    }
    
    if ([self isFleetCaptain]) {
        return @"FlCp";
    }
    
    if ([self isSquadron]) {
        return @"S";
    }
    
    if ([self isResourceUpgrade]) {
        return @"Res";
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
    NSString* externalId = self.externalId;

    NSString* fleetCaptainSpecial = [[equippedShip.squad.equippedFleetCaptain upgrade] special];

    DockEquippedUpgrade* equippedOnThisShipFleetCaptain = [equippedShip equippedFleetCaptain];
    DockFleetCaptain* fleetCaptainOnThisShip = (DockFleetCaptain*)equippedOnThisShipFleetCaptain.upgrade;
    int fleetCaptainOnThisShipTalentCount = [[fleetCaptainOnThisShip talentAdd] intValue];

    if ([upgrade isPlaceholder]) {
        return 0;
    }

    if ([upgrade isFleetCaptain]) {
        return [[upgrade cost] intValue];
    }
    
    if ([upgrade.externalId isEqualToString:@"captains_chair_r_72936r"] ||
        [upgrade.externalId isEqualToString:@"front-line_retrofit_r_72941r"]) {
        return [[upgrade cost] intValue];
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
        if (fleetCaptainOnThisShipTalentCount > 0) {
            NSArray* all = [equippedShip allUpgradesOfFaction: nil upType: @"Talent"];
            NSInteger talentCount = all.count;
            if (talentCount > 0) {
                NSInteger maxTalents = [equippedShip talentCount];
                if (talentCount < maxTalents) {
                    DockEquippedUpgrade* eu = all[0];
                    if (equippedUpgrade == eu) {
                        cost = 0;
                    }
                }
            }
        }
        if ([captainSpecial isEqualToString: @"BaselineTalentCostToThree"] && self.isFederation && !isSideboard) {
            cost = 3;
        }
        if ([captain.externalId isEqualToString:@"shinzon_71533"] && [upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"] && !isSideboard) {
            return 4;
        }
        if ([equippedUpgrade.specialTag hasPrefix:@"shinzon_ET_"]) {
            return 0;
        }
        if ([equippedUpgrade.specialTag hasPrefix:@"dna-enc_ET_"]) {
            return 0;
        }
        if ([upgrade.externalId isEqualToString:@"intercept_course_71808"] && ![equippedShip isResourceSideboard]) {
            if (![captain.externalId isEqualToString:@"karr_71808"] && ![captain.externalId isEqualToString:@"alpha_hirogen_71808"] && [captain.title rangeOfString:@"Hirogen"].location == NSNotFound) {
                cost += 5;
            }
        }
        if ([upgrade.externalId isEqualToString:@"mauk_to_vor_71999p"] && [captain.externalId isEqualToString:@"kurn_71999p"]) {
            cost = 3;
        }
        if ([upgrade.title isEqualToString:@"Kuvah'Magh"] && [captain.special isEqualToString:@"KuvahMagh2Less"]) {
            cost -= 2;
        }
    } else if ([upgrade isCrew] && ![upgrade isQMark]) {
        if (([captainSpecial isEqualToString: @"CrewUpgradesCostOneLess"] || [captainSpecial isEqualToString: @"hugh_71522"] ) && !isSideboard && ![upgrade isQMark]) {
            cost -= 1;
        }

        if ([upgradeSpecial isEqualToString: @"costincreasedifnotromulansciencevessel"]) {
            if (![ship isRomulanScienceVessel]) {
                cost += 5;
            }
        }
        
        if ([fleetCaptainSpecial isEqualToString: @"CrewUpgradesCostOneLess"] && !isSideboard) {
            cost -= 1;
        }

    } else if ([upgrade isWeapon] && ![upgrade isQMark]) {
        if ([upgradeSpecial isEqualToString: @"OnlyFedShipHV4CostPWVP1"]) {
            cost += [ship.attack intValue];
            if (equippedShip.isResourceSideboard) {
                cost = 5;
            }
            if (equippedShip.flagship != nil) {
                cost += equippedShip.flagship.attackAdd;
            }
            cost += 1;
        }
        if ([upgradeSpecial isEqualToString: @"OnlyFedShipHV4CostPWVP"]) {
            cost += [ship.attack intValue];
            if (equippedShip.isResourceSideboard) {
                cost = 5;
            }
            if (equippedShip.flagship != nil) {
                cost += equippedShip.flagship.attackAdd;
            }
        }
        if ([upgradeSpecial isEqualToString:@"OnlyXindiANDCostPWV"]) {
            cost += [ship.attack intValue];
            if (equippedShip.isResourceSideboard) {
                cost = 5;
                if (equippedShip.flagship != nil) {
                    cost += equippedShip.flagship.attackAdd;
                }
            }
        }
        if ([upgradeSpecial isEqualToString:@"CostPWV"]) {
            cost += [ship.attack intValue];
            if (equippedShip.isResourceSideboard) {
                cost = 5;
                if (equippedShip.flagship != nil) {
                    cost += equippedShip.flagship.attackAdd;
                }
            }
        }
        if ([captainSpecial isEqualToString: @"WeaponUpgradesCostOneLess"]) {
            cost -= 1;
        }
        if ([fleetCaptainSpecial isEqualToString: @"WeaponUpgradesCostOneLess"]) {
            cost -= 1;
        }
        if ([captainSpecial isEqualToString: @"AddOneWeaponAllKazonMinusOne"]) {
            if ([upgrade isKazon]) {
                cost -= 1;
            }
        }
        if ([equippedShip containsUpgradeWithId:@"romulan_hijackers_71802"] != nil) {
            if (![upgrade isFactionBorg]) {
                cost -= 1;
            }
        }
    } else if ([upgrade isTech] && ![upgrade isQMark]) {
        for (DockEquippedUpgrade* eu in equippedShip.upgrades) {
            if (![eu.upgrade isFleetCaptain] && [eu.upgrade.special isEqualToString:@"TechUpgradesCostOneLess"]) {
                cost -= 1;
            }
        }
        if ([ship.externalId isEqualToString:@"enterprise_nx_01_71526"] && [upgrade.externalId isEqualToString:@"enhanced_hull_plating_71526"]) {
            cost = 0;
        }
        if ([ship.externalId isEqualToString:@"u_s_s_pegasus_71801"]) {
            cost -= 1;
        }
        if ([fleetCaptainSpecial isEqualToString: @"TechUpgradesCostOneLess"]) {
            cost -= 1;
        }
        if ([equippedShip containsUpgradeWithId:@"romulan_hijackers_71802"] != nil) {
            if (![upgrade isFactionBorg]) {
                cost -= 1;
            }
        }
        if ([upgradeSpecial isEqualToString: @"costincreasedifnotromulansciencevesselAndNoMoreThanOnePerShip"]) {
            if (![ship isRomulanScienceVessel]) {
                cost += 5;
            }
        }
    }

    if ([captain.externalId isEqualToString:@"k_temoc_72009"]) {
        if (upgrade.isKlingon && !upgrade.isCaptain && !upgrade.isAdmiral) {
            cost -= 1;
        }
    }
    if ([captain.special isEqualToString:@"Ship2LessAndUpgrades1Less"] && ![upgrade isCaptain]) {
        cost -= 1;
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
    } else if ([upgradeSpecial isEqualToString: @"PlusFiveIfNotRaven"]) {
        if (![ship isRaven]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PlusFiveIfNotMirrorUniverse"]) {
        if (![ship isMirrorUniverse]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PlusFourIfNotPredatorClass"]) {
        if (![ship isPredatorClass]) {
            cost += 4;
        }
    } else if ([upgradeSpecial isEqualToString: @"PlusFiveIfNotGalaxyIntrepidSovereign"]) {
        if (!([ship isGalaxyClass] || [ship isIntrepidClass] || [ship isSovereignClass])) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString: @"PhaserStrike"] || [upgradeSpecial isEqualToString: @"CostPlusFiveExceptBajoranInterceptor"]) {
        if (![ship isBajoranInterceptor]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"PlusFiveIfNotRemanWarbird"]) {
        if (![ship isRemanWarbird]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"PlusFiveIfSkillOverFive"] && ![equippedShip isResourceSideboard]) {
        if ([captain.skill intValue] > 5) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"PlusFiveIfNotRegentsFlagship"]) {
        if (![ship.title isEqualToString:@"Regent's Flagship"]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"PlusFivePointsNonHirogen"]) {
        if ([ship.shipClass rangeOfString:@"Hirogen"].location == NSNotFound) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"PlusFiveIfNotRomulan"]) {
        if (![ship isRomulan]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"OPSPlusFiveNotRomulan"]) {
        if (![ship isRomulan]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"PlusFourIfNotGornRaider"]) {
        if (![ship.shipClass isEqualToString:@"Gorn Raider"]) {
            cost += 4;
        }
    } else if ([upgradeSpecial isEqualToString:@"PlusFiveIfNotKlingon"]) {
        if (![ship isKlingon]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"PlusFiveNotKlingonAndMustHaveComeAbout"]) {
        if (![ship isKlingon]) {
            cost += 5;
        }
    } else if ([upgradeSpecial isEqualToString:@"Plus4NotPrometheus"]) {
        if (![ship.title isEqualToString:@"U.S.S. Prometheus"]) {
            cost += 4;
        }
    } else if ([upgradeSpecial isEqualToString:@"Plus3NotKlingonAndNoMoreThanOnePerShip"]) {
        if (![ship isKlingon]) {
            cost += 3;
        }
    } else if ([upgradeSpecial isEqualToString:@"Plus2NotRomulanAndNoMoreThanOnePerShip"]) {
        if (![ship isRomulan]) {
            cost += 2;
        }
    }  else if ([upgradeSpecial isEqualToString:@"Hull4NoRearPlus5NonFed"]) {
        if (![ship isFederation]) {
            cost += 5;
        }
    }  else if ([upgradeSpecial isEqualToString:@"limited_max_weapon_3AndPlus5NonFed"]) {
        if (![ship isFederation]) {
            cost += 5;
        }
    }  else if ([upgradeSpecial isEqualToString:@"Plus5NotDominionAndNoMoreThanOnePerShip"]) {
        if (![ship isDominion]) {
            cost += 5;
        }
    }  else if ([upgradeSpecial isEqualToString:@"Plus5NotXindi"]) {
        if (![ship isXindi]) {
            cost += 5;
        }
    }  else if ([upgradeSpecial isEqualToString:@"OPSPlus4NotXindi"]) {
        if (![ship isXindi]) {
            cost += 4;
        }
    }  else if ([upgradeSpecial isEqualToString:@"OPSPlus5NotXindi"]) {
        if (![ship isXindi]) {
            cost += 5;
        }
    }  else if ([upgradeSpecial isEqualToString:@"Plus5NotKlingon"]) {
        if (![ship isKlingon]) {
            cost += 5;
        }
    }  else if ([upgradeSpecial isEqualToString:@"Plus4NotVulcan"]) {
        if (![ship isVulcan]) {
            cost += 4;
        }
    }  else if ([upgradeSpecial isEqualToString:@"Plus3NotFederationNoMoreThanOnePerShip"]) {
        if (![ship isFederation]) {
            cost += 3;
        }
    }  else if ([upgradeSpecial isEqualToString:@"Plus5NotFederationNoMoreThanOnePerShip"]) {
        if (![ship isFederation]) {
            cost += 5;
        }
    }  else if ([upgradeSpecial isEqualToString:@"Plus5NotKazonNoMoreThanOnePerShip"]) {
        if (![ship isKazon]) {
            cost += 5;
        }
    } else if ([upgradeSpecial hasPrefix:@"Plus3NotShipClass_"]) {
        NSString* shipClass = [ship.shipClass stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"Plus3NotShipClass_%@",shipClass]]) {
            cost += 3;
        }
    } else if ([upgradeSpecial hasPrefix:@"Plus3NotShip_"]) {
        NSString* shipName = [ship.title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"Plus3NotShip_%@",shipName]]) {
            cost += 3;
        }
    } else if ([upgradeSpecial hasPrefix:@"Plus4NotShipClass_"]) {
        NSString* shipClass = [ship.shipClass stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"Plus4NotShipClass_%@",shipClass]]) {
            cost += 4;
        }
    } else if ([upgradeSpecial hasPrefix:@"Plus4NotShip_"]) {
        NSString* shipName = [ship.title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"Plus4NotShip_%@",shipName]]) {
            cost += 4;
        }
    } else if ([upgradeSpecial hasPrefix:@"Plus5NotShipClass_"]) {
        NSString* shipClass = [ship.shipClass stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"Plus5NotShipClass_%@",shipClass]]) {
            cost += 5;
        }
    } else if ([upgradeSpecial hasPrefix:@"Plus5NotShip_"]) {
        NSString* shipName = [ship.title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"Plus5NotShip_%@",shipName]]) {
            cost += 5;
        }
    } else if ([upgradeSpecial hasPrefix:@"Plus6NotShipClass_"]) {
        NSString* shipClass = [ship.shipClass stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"Plus6NotShipClass_%@",shipClass]]) {
            cost += 6;
        }
    } else if ([upgradeSpecial hasPrefix:@"Plus6NotShip_"]) {
        NSString* shipName = [ship.title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"Plus6NotShip_%@",shipName]]) {
            cost += 6;
        }
    } else if ([upgradeSpecial hasPrefix:@"OPSPlus5NotShipClass_"]) {
        NSString* shipClass = [ship.shipClass stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"OPSPlus5NotShipClass_%@",shipClass]]) {
            cost += 5;
        }
    } else if ([upgradeSpecial hasPrefix:@"OPSPlus3NotShipClass_"]) {
        NSString* shipClass = [ship.shipClass stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"OPSPlus3NotShipClass_%@",shipClass]]) {
            cost += 3;
        }
    }

    if (!isSideboard) {
        if ([captainSpecial isEqualToString: @"OneDominionUpgradeCostsMinusTwo"]) {
            if ([upgrade isDominion]) {
                DockEquippedUpgrade* most = [equippedShip mostExpensiveUpgradeOfFaction: @"Dominion" upType: nil];

                if (most.upgrade == self && (equippedUpgrade == nil || equippedUpgrade == most)) {
                    cost -= 2;
                }
            }
        } else if ([captainSpecial isEqualToString: @"VulcanAndFedTechUpgradesMinus2"]) {
            if ([upgrade isTech] && ([upgrade isFederation] || [upgrade isVulcan]) && ![upgrade isQMark]) {
                cost -= 2;
            }
        } else if ([captainSpecial isEqualToString: @"AddTwoCrewSlotsDominionCostBonus"]) {
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
        } else if ([captainSpecial isEqualToString: @"AllUpgradesMinusOneOnIndepedentShip"]) {
            if ([equippedShip hasFaction: @"Independent"] && ![self isOfficer] && ![self isCaptain] && ![self isAdmiral]) {
                cost -= 1;
            }
        } else if ([captainSpecial isEqualToString: @"KlingonUpgradesCostOneLess"]) {
            if ([self isKlingon] && ![self isOfficer] && ![self isCaptain] && ![self isAdmiral]) {
                cost -= 1;
            }
        } else if ([captainSpecial isEqualToString:@"RemanBodyguardsLess2"]) {
            if ([[self title] isEqualToString:@"Reman Bodyguards"]) {
                cost -= 2;
            }
        } else if ([captainSpecial isEqualToString:@"FedCrewUpgradesCostOneLess"]) {
            if ([self isCrew] && [self isFederation]) {
                cost -= 1;
            }
        }
    }

    BOOL hasExchange = NO;
    NSString* exFac1;
    NSString* exFac2;
    int costWithoutPenalty = cost;
    if ([equippedShip.squad.resource.externalId isEqualToString:@"officer_exchange_program_71996a"] && equippedShip.squad.resourceAttributes.length > 3) {
        NSArray* selectedFactions = [equippedShip.squad.resourceAttributes componentsSeparatedByString:@" & "];
        if (selectedFactions.count == 2) {
            hasExchange = YES;
            exFac1 = [selectedFactions objectAtIndex:0];
            exFac2 = [selectedFactions objectAtIndex:1];
        }
    }
    
    if (![upgrade isOfficer] && !factionsMatch(ship, self) && !equippedShip.isResourceSideboard && !factionsMatch(self, equippedShip.flagship)) {
        if ([captainSpecial isEqualToString: @"UpgradesIgnoreFactionPenalty"] && ![upgrade isCaptain] && ![upgrade isAdmiral]) {
            // do nothing
        } else if (self.isQContinuum) {
        } else if ([captainSpecial isEqualToString: @"NoPenaltyOnFederationOrBajoranShip"]  && [upgrade isCaptain]) {
            if (!([ship isFederation] || [ship isBajoran])) {
                cost += 1;
            }
        } else if ([captainSpecial isEqualToString: @"NoPenaltyOnFederationShip"]  && [upgrade isCaptain]) {
            if (!([ship isFederation])) {
                cost += 1;
            }
        } else if ([captainSpecial isEqualToString: @"CaptainAndTalentsIgnoreFactionPenalty"] &&
                   ([upgrade isTalent] || [upgrade isCaptain])) {
        } else if ([captainSpecial isEqualToString: @"hugh_71522"] &&
                   [upgrade isFactionBorg]) {
        } else if ([captainSpecial isEqualToString: @"lore_71522"] &&
                   [upgrade isTalent]) {
        } else if ([captainSpecial isEqualToString: @"NoPenaltyOnTalent"] &&
                   [upgrade isTalent]) {
        } else if ([externalId isEqualToString: @"elim_garak_71786"]) {
        } else if ([upgradeSpecial isEqualToString: @"add_one_tech_no_faction_penalty_on_vulcan"] && [ship isVulcan]) {
        } else if ([fleetCaptainOnThisShip isIndependent] && [ship isIndependent] && [upgrade isCaptain]) {
        } else if ([upgradeSpecial isEqualToString:@"NoPenaltyOnKlingonShip"]) {
            if (!([ship isKlingon])) {
                cost += 1;
            }
        } else if ([captain.externalId isEqualToString:@"k_temoc_72009"] && !upgrade.isKlingon) {
            if (![upgrade isAdmiral] && ![upgrade isCaptain]) {
                cost += 2;
            }
        } else if ([upgradeSpecial isEqualToString:@"CaptainIgnoresPenalty"]) {
        } else if ([equippedShip.ship.externalId isEqualToString:@"quark_s_treasure_72013"] && [upgrade isTech]) {
        } else if ([equippedShip.ship.externalId isEqualToString:@"quark_s_treasure_72013"] && [upgrade isCrew]) {
        } else if ([equippedShip containsUpgradeWithId:@"romulan_hijackers_71802"] != nil && [upgrade isRomulan] && ![upgrade isCaptain] && ![upgrade isAdmiral]) {
        } else if ([upgradeSpecial isEqualToString:@"no_faction_penalty_on_vulcan"] && [ship isVulcan]) {
        } else if ([self.externalId isEqualToString:@"captured_c_72937"]) {
        } else if ([self.externalId isEqualToString:@"captured_t_72937"]) {
        } else if ([self.externalId isEqualToString:@"captured_w_72937"]) {
        } else if ([equippedShip hasFaction:self.faction]) {
        } else {
            if (upgrade.isAdmiral) {
                cost += 3;
            } else {
                cost += 1;
            }
        }

    }
    if (hasExchange) {
        if ((targetHasFaction(exFac1, upgrade) && targetHasFaction(exFac2, ship)) || (targetHasFaction(exFac2, upgrade) && targetHasFaction(exFac1, ship))) {
            if (cost > costWithoutPenalty && ![upgrade isQMark]) {
                if (upgrade.isCrew || upgrade.isCaptain || upgrade.isAdmiral) {
                    cost = costWithoutPenalty;
                }
            }
            if (upgrade.isCaptain || upgrade.isAdmiral) {
                cost -= 1;
            }
        }
    }

    if ([[upgrade externalId] isEqualToString: @"borg_ablative_hull_armor_71283"]) {
        if ([[ship externalId] isEqualToString: @"tactical_cube_138_71444"]) {
            cost = 7;
        }
    }

    if ([upgrade isWeapon] && [equippedShip containsUpgradeWithId: @"sakonna_gavroche"] != nil && ![upgrade isQMark]) {
        if (cost <= 5) {
            cost -= 2;
        }
    }


    if (cost < 0) {
        cost = 0;
    }
    if ([upgradeSpecial isEqualToString:@"BSVT"]) {
        if ([ship.shipClass isEqualToString:@"Borg Sphere"]) {
            cost = -15;
        } else {
            cost = -10;
        }
    }
    return cost;
}

-(int)additionalWeaponSlots
{
    NSString* special = self.special;
    NSString* externalId = self.externalId;

    if ([special isEqualToString: @"AddTwoWeaponSlots"]) {
        return 2;
    }
    if ([special isEqualToString: @"AddsOneWeaponOneTech"] || [special isEqualToString: @"addoneweaponslot"] || [special isEqualToString: @"AddOneWeaponAllKazonMinusOne"]) {
        return 1;
    }
    if ([special isEqualToString: @"sakonna_gavroche"]) {
        return 1;
    }
    if ([externalId isEqualToString: @"quark_weapon_71786"]) {
        return 1;
    }
    if ([special isEqualToString: @"only_suurok_class_limited_weapon_hull_plus_1"]) {
        return 1;
    }
    if ([special isEqualToString:@"AddHiddenWeapon"]) {
        return 1;
    }
    if ([special isEqualToString:@"AddTwoWeaponSlotsAndNoMoreThanOnePerShip"]) {
        return 2;
    }
    if ([externalId isEqualToString:@"maintenance_crew_w_72022"]) {
        return 1;
    }
    if ([special isEqualToString:@"addoneweaponslotfortorpedoes"]) {
        return 1;
    }
    if ([special isEqualToString:@"delta_shift_w_72320p"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"borg_support_vehicle_token_w_72006"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"main_batteries_72321p"]) {
        return 1;
    }
    if ([special isEqualToString:@"addoneweaponslot1xindi2less"]) {
        return 1;
    }
    return 0;
}

-(int)additionalTechSlots
{
    NSString* special = self.special;
    NSString* externalId = self.externalId;

    if ([special isEqualToString: @"AddsOneWeaponOneTech"]) {
        return 1;
    }
    if ([special isEqualToString: @"add_one_tech_no_faction_penalty_on_vulcan"]) {
        return 1;
    }
    if ([externalId isEqualToString: @"vulcan_high_command_2_0_71446"]) {
        return 2;
    }
    if ([special isEqualToString: @"addonetechslot"] || [externalId isEqualToString: @"vulcan_high_command_1_1_71446"]) {
        return 1;
    }
    if ([externalId isEqualToString: @"quark_71786"] || [externalId isEqualToString:@"first_maje_71793"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"systems_upgrade_71998p"] || [externalId isEqualToString:@"systems_upgrade_c_71998p"] || [externalId isEqualToString:@"systems_upgrade_w_71998p"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"cargo_hold_11_72013"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"cargo_hold_02_72013"]) {
        return 2;
    }
    if ([special isEqualToString:@"Add3FedTech4Less"]) {
        return 3;
    }
    if ([externalId isEqualToString:@"maintenance_crew_t_72022"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"AddOneTechMinus1"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"delta_shift_t_72320p"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"borg_support_vehicle_token_t_72006"]) {
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
    NSString* special = self.special;
    if ([special isEqualToString: @"Add_Crew_1"]) {
        return 1;
    }
    if ([special isEqualToString:@"Add2HiddenCrew5"]) {
        return 2;
    }
    if ([externalId isEqualToString:@"cargo_hold_11_72013"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"cargo_hold_20_72013"]) {
        return 2;
    }
    if ([externalId isEqualToString:@"maintenance_crew_c_72022"]) {
        return 2;
    }
    if ([externalId isEqualToString:@"maintenance_crew_t_72022"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"maintenance_crew_w_72022"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"delta_shift_c_72320p"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"borg_support_vehicle_token_c_72006"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"comm_station_72940"]) {
        return 1;
    }
    
    return 0;
}

-(int)additionalBorgSlots
{
    NSString* externalId = self.externalId;

    if ([externalId isEqualToString: @"borg_alliance_71511"] || [self.special isEqualToString:@"AddOneBorgSlot"]) {
        return 1;
    }
    if ([externalId isEqualToString:@"borg_support_vehicle_token_72006"]) {
        return 1;
    }
    return 0;
}

-(int)additionalTalentSlots
{
    if ([self.special isEqualToString: @"addonetalentslot"] || [self.externalId isEqualToString:@"william_t_riker_71996"]) {
        return 1;
    }
    if ([self.externalId isEqualToString:@"delta_shift_e_72320p"]) {
        return 1;
    }
    return 0;
}

-(int)additionalHull
{
    if ([self.externalId isEqualToString: @"combat_vessel_variant_71508"]) {
        return 1;
    }
    if ([self.special isEqualToString: @"only_suurok_class_limited_weapon_hull_plus_1"]) {
        return 1;
    }
    return 0;
}

-(int)additionalAttack
{
    if ([self.externalId isEqualToString: @"combat_vessel_variant_71508"]) {
        return 1;
    }
    if ([self.special isEqualToString: @"only_suurok_class_limited_weapon_hull_plus_1"]) {
        return 1;
    }
    if ([self.externalId isEqualToString:@"assault_vessel_upgrade_c_71803"] || [self.externalId isEqualToString:@"assault_vessel_upgrade_t_71803"] || [self.externalId isEqualToString:@"assault_vessel_upgrade_w_71803"] ) {
        return 1;
    }
    return 0;
}

-(int)additionalShield
{
    if ([self.externalId isEqualToString:@"assault_vessel_upgrade_c_71803"] || [self.externalId isEqualToString:@"assault_vessel_upgrade_t_71803"] || [self.externalId isEqualToString:@"assault_vessel_upgrade_w_71803"] || [self.externalId isEqualToString:@"systems_upgrade_71998p"] || [self.externalId isEqualToString:@"systems_upgrade_c_71998p"] || [self.externalId isEqualToString:@"systems_upgrade_w_71998p"] || [self.externalId isEqualToString:@"immersion_shielding_72014"]) {
        return 1;
    }
    if ([self.externalId isEqualToString:@"unimatrix_shielding_72014"]) {
        return 2;
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

-(NSString*)uniqueAsString
{
    return uniqueAsString(self);
}


@end
