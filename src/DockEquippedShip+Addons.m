#import "DockEquippedShip+Addons.h"

#import "DockAdmiral+Addons.h"
#import "DockCaptain+Addons.h"
#import "DockConstants.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockEquippedUpgrade.h"
#import "DockEquippedFlagship.h"
#import "DockErrors.h"
#import "DockFleetCaptain+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockResource+Addons.h"
#import "DockSet+Addons.h"
#import "DockSetItem+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"
#import "DockSideboard+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"

#import "NSMutableDictionary+Addons.h"

@implementation DockEquippedShip (Addons)

+(NSSet*)keyPathsForValuesAffectingSortedUpgrades
{
    return [NSSet setWithObjects: @"upgrades", @"ship", @"flagship", nil];
}

+(NSSet*)keyPathsForValuesAffectingSortedUpgradesWithFlagship
{
    return [NSSet setWithObjects: @"upgrades", @"ship", @"flagship", nil];
}

+(NSSet*)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects: @"upgrades", @"ship", @"flagship", nil];
}

+(NSSet*)keyPathsForValuesAffectingStyledDescription
{
    return [NSSet setWithObjects: @"ship", @"flagship", nil];
}

+(NSSet*)keyPathsForValuesAffectingFormattedCost
{
    return [NSSet setWithObjects: @"cost", nil];
}

-(NSString*)title
{
    if ([self isResourceSideboard]) {
        return self.squad.resource.title;
    }

    return self.ship.title;
}

-(NSString*)plainDescription
{
    if ([self isResourceSideboard]) {
        return self.squad.resource.title;
    }

    return [self.ship plainDescription];
}

-(NSString*)descriptiveTitle
{
    if ([self isResourceSideboard]) {
        return self.squad.resource.title;
    }

    NSString* s = [self.ship descriptiveTitle];
    return s;
}

-(NSString*)descriptiveTitleWithSet
{
    if ([self isResourceSideboard]) {
        return [NSString stringWithFormat: @"%@ [%@]", [self descriptiveTitle], [self.squad.resource setCode]];
    }
    return [NSString stringWithFormat: @"%@ [%@]", [self descriptiveTitle], [self.ship setCode]];
}

-(NSString*)upgradesDescription
{
    NSArray* sortedUpgrades = [self sortedUpgrades];
    NSMutableArray* upgradeTitles = [NSMutableArray arrayWithCapacity: sortedUpgrades.count];

    for (DockEquippedUpgrade* eu in sortedUpgrades) {
        DockUpgrade* upgrade = eu.upgrade;

        if (![upgrade isPlaceholder]) {
            [upgradeTitles addObject: upgrade.title];
        }
    }
    return [upgradeTitles componentsJoinedByString: @", "];
}

-(NSDictionary*)asJSON
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    DockShip* ship = self.ship;
    if (ship == nil) {
        [json setObject: @YES forKey: @"sideboard"];
    } else {
        [json setObject: ship.externalId forKey: @"shipId"];
        [json setObject: ship.title forKey: @"shipTitle"];
        DockFlagship* flagship = self.flagship;
        if (flagship != nil) {
            [json setObject: flagship.externalId forKey: @"flagship"];
        }
    }
    [json setObject: [NSNumber numberWithInt: self.cost] forKey: @"calculatedCost"];
    DockEquippedUpgrade* equippedCaptain = self.equippedCaptain;
    if (equippedCaptain) {
        [json setObject: [equippedCaptain asJSON]  forKey: @"captain"];
    }
    NSArray* upgrades = [self sortedUpgrades];
    if (upgrades.count > 0) {
        NSMutableArray* upgradesArray = [[NSMutableArray alloc] initWithCapacity: upgrades.count];
        for (DockEquippedUpgrade* eu in upgrades) {
            if (![eu isPlaceholder] && ![eu.upgrade isCaptain]) {
                [upgradesArray addObject: [eu asJSON]];
            }
        }
        [json setObject: upgradesArray forKey: @"upgrades"];
    }
    return [NSDictionary dictionaryWithDictionary: json];
}

-(NSString*)asPlainTextFormat
{
    NSMutableString* textFormat = [[NSMutableString alloc] init];

    DockResource* resource = self.squad.resource;

    NSString* s = [NSString stringWithFormat: @"%@ [%@] (%d)", self.plainDescription, self.ship.setCode, [self baseCost]];
    [textFormat appendString: s];
    [textFormat appendString: @"\n"];

    DockFlagship* fs = [self flagship];
    if (fs) {
        s = [NSString stringWithFormat: @"%@ [%@] (%@)\n", [fs plainDescription], fs.setCode, [resource cost]];
        [textFormat appendString: s];
    }
    for (DockEquippedUpgrade* upgrade in self.sortedUpgrades) {
        if (![upgrade isPlaceholder]) {
            [textFormat appendString: [upgrade asPlainTextFormat]];
        }
    }

    if (![self isResourceSideboard]) {
        s = [NSString stringWithFormat: @"Total (%d)\n", self.cost];
        [textFormat appendString: s];
    }

    [textFormat appendString: @"\n"];

    return [NSString stringWithString: textFormat];
}

-(NSString*)factionCode
{
    return factionCode(self.ship);
}

-(BOOL)hasFaction:(NSString*)faction
{
    if ([faction isEqualToString:@"Independent"]) {
        if ([self containsUpgradeWithId:@"captured_c_72937"] != nil) {
            return YES;
        } else if ([self containsUpgradeWithId:@"captured_t_72937"] != nil) {
            return YES;
        } else if ([self containsUpgradeWithId:@"captured_w_72937"] != nil) {
            return YES;
        }
    }
    return targetHasFaction(faction, self.ship) || targetHasFaction(faction, self.flagship);
}

-(int)baseCost
{
    if ([self isResourceSideboard]) {
        return [self.squad.resource.cost intValue];
    }

    return [self.ship.cost intValue];
}

-(int)attack
{
    int attack = [self.ship.attack intValue] + [self.flagship attackAdd];
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        attack += [upgrade additionalAttack];
    }
    return attack;
}

-(int)agility
{
    return [self.ship.agility intValue] + [self.flagship agilityAdd];
}

-(int)hull
{
    int hull = [self.ship.hull intValue] + [self.flagship hullAdd];
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        hull += [upgrade additionalHull];
    }
    return hull;
}

-(int)shield
{
    int shield = [self.ship.shield intValue] + [self.flagship shieldAdd];
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        shield += [upgrade additionalShield];
        if ([upgrade.externalId isEqualToString:@"front-line_retrofit_r_72941r"]){
            shield ++;
        }
    }
    return shield;
}

-(NSString*)attackString
{
    return [[NSNumber numberWithInt: self.attack] stringValue];
}

-(NSString*)agilityString
{
    return [[NSNumber numberWithInt: self.agility] stringValue];
}

-(NSString*)hullString
{
    return [[NSNumber numberWithInt: self.hull] stringValue];
}

-(NSString*)shieldString
{
    return [[NSNumber numberWithInt: self.shield] stringValue];
}

-(int)cost
{
    int cost = [self.ship.cost intValue];

    for (DockEquippedUpgrade* upgrade in self.upgrades) {
        cost += [upgrade cost];
    }
    
    if (self.flagship != nil) {
        cost += 10;
    }

    if ([self.captain.special isEqualToString:@"Ship2LessAndUpgrades1Less"]) {
        cost -= 2;
        if (cost < 0) {
            cost = 0;
        }
    }
    
    return cost;
}

-(DockEquippedUpgrade*)equippedCaptain
{
    if (self.ship.isFighterSquadron) {
        return nil;
    }
    
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;

        if ([upgrade.upType isEqualToString: @"Captain"]) {
            if ([self upgradesWithSpecialTag:@"AdditionalCaptain"].count == 0 || ![eu.specialTag isEqualToString:@"AdditionalCaptain"]) {
                return eu;
            }
        }
    }
    return nil;
}

-(DockCaptain*)captain
{
    return (DockCaptain*)[[self equippedCaptain] upgrade];
}

-(DockAdmiral*)admiral
{
    return (DockAdmiral*)[[self equippedAdmiral] upgrade];
}

-(BOOL)isResourceSideboard
{
    return self.ship == nil;
}

-(BOOL)isFighterSquadron
{
    return [self.ship isFighterSquadron];
}

+(DockEquippedShip*)equippedShipWithShip:(DockShip*)ship
{
    NSManagedObjectContext* context = ship.managedObjectContext;
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"EquippedShip"
                                              inManagedObjectContext: context];
    DockEquippedShip* es = [[DockEquippedShip alloc] initWithEntity: entity
                                     insertIntoManagedObjectContext: context];
    es.ship = ship;
    [es establishPlaceholders];
    
    if ([es.ship.externalId isEqualToString:@"enterprise_nx_01_71526"]) {
        [es addUpgrade:[DockUpgrade upgradeForId:@"enhanced_hull_plating_71526" context:context]];
    }

    return es;
}

+(DockEquippedShip*)import:(NSDictionary*)esDict context:(NSManagedObjectContext *)context
{
    DockShip* ship = [DockShip shipForId: esDict[@"shipId"] context: context];
    DockEquippedShip* es = [DockEquippedShip equippedShipWithShip: ship];
    NSString* flagshipId = esDict[@"flagship"];
    if (flagshipId) {
        DockFlagship* flagship = [DockFlagship flagshipForId: flagshipId context: context];
        es.flagship = flagship;
    }
    [es importUpgrades: esDict];
    return es;
}

-(void)importUpgrades:(NSDictionary*)esDict
{
    [self removeAllUpgrades];
    NSManagedObjectContext* context = self.managedObjectContext;
    NSDictionary* upgradeDict = esDict[@"captain"];
    NSString* captainId = upgradeDict[@"upgradeId"];
    [self addUpgrade: [DockCaptain captainForId: captainId context: context]];
    NSArray* upgrades = esDict[@"upgrades"];
    for (upgradeDict in upgrades) {
        NSString* upgradeId = upgradeDict[@"upgradeId"];
        DockUpgrade* upgrade = [DockUpgrade upgradeForId: upgradeId context: context];
        DockEquippedUpgrade* eu = [self addUpgrade: upgrade maybeReplace: nil establishPlaceholders: NO respectLimits: NO];
        NSNumber* overriddenNumber = upgradeDict[@"costIsOverridden"];
        BOOL overridden = [overriddenNumber boolValue];
        if (overridden) {
            eu.overridden = overriddenNumber;
            eu.overriddenCost = upgradeDict[@"overriddenCost"];
        }
    }
    [self removeIllegalUpgrades];
    [self establishPlaceholders];
}

-(DockEquippedShip*)duplicate
{
    DockEquippedShip* newShip;
    if (self.isResourceSideboard) {
        newShip = [DockSideboard sideboard: self.managedObjectContext];
        [newShip removeAllUpgrades];
    } else {
        newShip = [DockEquippedShip equippedShipWithShip: self.ship];
        newShip.flagship = self.flagship;
    }

    DockCaptain* captain = [self captain];
    [newShip addUpgrade: captain maybeReplace: nil establishPlaceholders: NO respectLimits: YES];

    for (DockEquippedUpgrade* equippedUpgrade in self.sortedUpgrades) {
        DockUpgrade* upgrade = [equippedUpgrade upgrade];

        if (![upgrade isPlaceholder] && ![upgrade isCaptain]) {
            DockEquippedUpgrade* duppedUpgrade = [newShip addUpgrade: equippedUpgrade.upgrade maybeReplace: nil establishPlaceholders: NO respectLimits: NO];
            duppedUpgrade.overridden = equippedUpgrade.overridden;
            duppedUpgrade.overriddenCost = equippedUpgrade.overriddenCost;
        }
    }
    [newShip establishPlaceholders];
    return newShip;
}

-(int)equipped:(NSString*)upType
{
    int count = 0;

    for (DockEquippedUpgrade* eu in self.upgrades) {
        if ([eu.upgrade.upType isEqualToString: upType]) {
            count += 1;
        }
    }
    return count;
}

-(void)removeOverLimit:(NSString*)upType current:(int)current limit:(int)limit
{
    int amountToRemove = current - limit;
    [self removeUpgradesOfType: upType targetCount: amountToRemove];
}

-(void)establishPlaceholdersForType:(NSString*)upType limit:(int)limit
{
    NSManagedObjectContext* context = self.managedObjectContext;
    int current = [self equipped: upType];

    if (current > limit) {
        [self removeOverLimit: upType current: current limit: limit];
    } else {
        for (int i = current; i < limit; ++i) {
            DockUpgrade* upgrade = [DockUpgrade placeholder: upType inContext: context];
            [self addUpgrade: upgrade maybeReplace: nil establishPlaceholders: NO];
        }
    }
}

-(NSString*)shipFaction
{
    return self.ship.faction;
}

-(void)establishPlaceholders
{
    if (self.captainCount > 0) {
        DockCaptain* captain = [self captain];

        if (captain == nil) {
            NSString* faction = self.shipFaction;

            if ([faction isEqualToString: @"Independent"] || [faction isEqualToString: @"Bajoran"]) {
                faction = @"Federation";
            }

            DockUpgrade* zcc = nil;
            if (self.isResourceSideboard) {
                zcc = [DockCaptain zeroCostCaptain: faction context: self.managedObjectContext];
            } else if ([self containsUpgradeWithId:@"romulan_hijackers_71802"]) {
                zcc = [DockCaptain zeroCostCaptain:@"Romulan" context:self.managedObjectContext];
            } else {
                zcc = [DockCaptain zeroCostCaptainForShip: self.ship];
            }
            [self addUpgrade: zcc maybeReplace: nil establishPlaceholders: NO];
        }
        int current = [self equipped: @"Captain"];
        if (current > self.captainCount) {
            [self removeOverLimit: @"Captain" current: current limit: self.captainCount];
        } else {
            for (int i = current; i < self.captainCount; ++i) {
                DockUpgrade* zcc = [DockCaptain zeroCostCaptainForShip: self.ship];
                if ([self.squad.resource.externalId isEqualToString:@"fleet_commander_72323r"] && ![self.captain isPlaceholder]) {
                    zcc = [DockUpgrade placeholder:@"Captain" inContext:self.managedObjectContext];
                }
                [self addUpgrade: zcc maybeReplace: nil establishPlaceholders: NO];
            }
        }
    }

    [self establishPlaceholdersForType: @"Talent" limit: self.talentCount];
    [self establishPlaceholdersForType: @"Crew" limit: self.crewCount];
    [self establishPlaceholdersForType: @"Weapon" limit: self.weaponCount];
    [self establishPlaceholdersForType: @"Tech" limit: self.techCount];
    [self establishPlaceholdersForType: @"Borg" limit: self.borgCount];
    [self establishPlaceholdersForType: @"Squadron" limit:self.squadronUpgradeCount];
}

-(DockEquippedUpgrade*)findPlaceholder:(NSString*)upType
{
    for (DockEquippedUpgrade* eu in self.upgrades) {
        if ([eu isPlaceholder] && [eu.upgrade.upType isEqualToString: upType]) {
            return eu;
        }
    }
    return nil;
}

-(void)removeAllTalents
{
    NSMutableSet* onesToRemove = [NSMutableSet setWithCapacity: 0];

    for (DockEquippedUpgrade* eu in self.upgrades) {
        if ([eu.upgrade isTalent]) {
            [onesToRemove addObject: eu];
        }
    }

    for (DockEquippedUpgrade* eu in onesToRemove) {
        [self removeUpgradeInternal: eu];
    }
}

-(void)removeAllUpgrades
{
    NSMutableSet* onesToRemove = [NSMutableSet setWithCapacity: 0];

    for (DockEquippedUpgrade* eu in self.upgrades) {
        [onesToRemove addObject: eu];
    }

    for (DockEquippedUpgrade* eu in onesToRemove) {
        [self removeUpgradeInternal: eu];
    }
}

-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade ignoreInstalled:(BOOL)ignoreInstalled
{
    return [self canAddUpgrade: upgrade ignoreInstalled: NO validating: YES];
}

-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade ignoreInstalled:(BOOL)ignoreInstalled validating:(BOOL)validating
{
    DockCaptain* captain = [self captain];

    if ([upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"]) {
        if (![captain.externalId isEqualToString:@"shinzon_71533"]) {
            return NO;
        }
    }
    
    if (!upgrade.isPlaceholder && [upgrade isTalent] && [self containsUpgradeWithId:@"shinzon_romulan_talents_71533"] != nil) {
        int talents = 0;

        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"shinzon_ET_"]) {
                    talents ++;
                }
            }
        }

        if (![upgrade isRomulan]) {
            int artificalLimit = [upgrade limitForShip: self] - talents - 4;
            if (!validating) {
                artificalLimit ++;
            }
            return artificalLimit > 0;
            //return NO;
        }
    }
    
    if (!upgrade.isPlaceholder && [upgrade isTalent] && [self containsUpgradeWithId:@"dna_encoded_message_72938"] != nil) {
        int talents = 0;
        
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"dna-enc_ET_"]) {
                    talents ++;
                }
            }
        }
        
        if (![upgrade isKlingon]) {
            int artificalLimit = [upgrade limitForShip: self] - talents - 3;
            if (!validating) {
                artificalLimit ++;
            }
            return artificalLimit > 0;
            //return NO;
        }
    }
    
    if (!upgrade.isPlaceholder && [upgrade isTech] && [self containsUpgradeWithSpecial:@"Add3FedTech4Less"] != nil) {
        int tech = 0;
        
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isTech] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"fed3_tech_"]) {
                    tech ++;
                }
            }
        }
        
        if (![upgrade isFederation] || [upgrade costForShip:self] > 4) {
            int artificalLimit = [upgrade limitForShip: self] - tech - 3;
            if (!validating) {
                artificalLimit ++;
            }
            return artificalLimit > 0;
            //return NO;
        }
    }
    
    if (!upgrade.isPlaceholder && [upgrade isTech] && [self containsUpgradeWithSpecial:@"AddOneTechMinus1"] != nil) {
        int tech = 0;
        
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isTech] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"nijil_tech_"]) {
                    tech ++;
                }
            }
        }
        
        if (![upgrade isRomulan]) {
            int artificalLimit = [upgrade limitForShip: self] - tech - 1;
            if (!validating) {
                artificalLimit ++;
            }
            return artificalLimit > 0;
            //return NO;
        }
    }
    
    if (!upgrade.isPlaceholder && [upgrade isWeapon] && [self containsUpgradeWithSpecial:@"addoneweaponslotfortorpedoes"] != nil) {
        int torp = 0;
        
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isWeapon] && !eu.isPlaceholder) {
                if (![eu.title hasPrefix:@"Photon Torpedoes"]) {
                    torp ++;
                }
            }
        }
        
        if (![upgrade.title hasPrefix:@"Photon Torpedoes"]) {
            int artificalLimit = [upgrade limitForShip: self] - torp - 1;
            if (!validating) {
                artificalLimit ++;
            }
            return artificalLimit > 0;
            //return NO;
        }
    }
    
    if ([upgrade.externalId isEqualToString:@"first_maje_71793"]) {
        if (![captain isKazon]) {
            return NO;
        }
    } else if (![upgrade isPlaceholder] && [upgrade isTalent] && [captain isKazon] && [self.ship isKazon]) {
        if (self.talentCount == 1) {
            return NO;
        } else {
            int talents = self.talentCount;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    talents --;
                }
            }
            if (talents == 1 && ![upgrade.externalId isEqualToString:@"first_maje_71793"]) {
                if ([self containsUpgradeWithId:@"first_maje_71793"] == nil && validating) {
                    return NO;
                }
            } else if (talents < 1 && ![upgrade.externalId isEqualToString:@"first_maje_71793"]) {
                return NO;
            }
        }
    }
    
    if (![upgrade isPlaceholder] && [upgrade isTalent] && [self.captain.externalId isEqualToString:@"slar_71797"]) {
        if (self.talentCount == 1) {
            if (![upgrade.externalId isEqualToString:@"salvage_71797"]) {
                return NO;
            }
        } else {
            int talents = self.talentCount;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                        talents --;
                    }
                }
            }
            if (talents == 1 && ![upgrade.externalId isEqualToString:@"salvage_71797"]) {
                if ([self containsUpgradeWithId:@"salvage_71797"] == nil && validating) {
                    return NO;
                }
            } else if (talents < 1 && ![upgrade.externalId isEqualToString:@"salvage_71797"]) {
                return NO;
            }
        }
    }

    if (![upgrade isPlaceholder] && [upgrade isTalent] && [self.captain.externalId isEqualToString:@"kurn_71999p"]) {
        if (self.talentCount == 1) {
            if (![upgrade.externalId isEqualToString:@"mauk_to_vor_71999p"]) {
                return NO;
            }
        } else {
            int talents = self.talentCount;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                        talents --;
                    }
                }
            }
            if (talents == 1 && ![upgrade.externalId isEqualToString:@"mauk_to_vor_71999p"]) {
                if ([self containsUpgradeWithId:@"mauk_to_vor_71999p"] == nil && validating) {
                    return NO;
                }
            } else if (talents < 1 && ![upgrade.externalId isEqualToString:@"mauk_to_vor_71999p"]) {
                return NO;
            }
        }
    }
    
    if (!upgrade.isPlaceholder && [upgrade isTalent] && [self.captain.externalId isEqualToString:@"k_temoc_72009"]) {
        if (!upgrade.isKlingon) {
            return NO;
        }
    }
    
    if (![upgrade isPlaceholder] && [upgrade isTalent] && [self.captain.externalId isEqualToString:@"brunt_72013"]) {
        if (self.talentCount == 1) {
            if (![upgrade.title isEqualToString:@"Grand Nagus"]) {
                return NO;
            }
        } else {
            int talents = self.talentCount;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                        talents --;
                    }
                }
            }
            if (talents == 1 && ![upgrade.title isEqualToString:@"Grand Nagus"]) {
                if ([self containsUpgradeWithName:@"Grand Nagus"] == nil && validating) {
                    return NO;
                }
            } else if (talents < 1 && ![upgrade.title isEqualToString:@"Grand Nagus"]) {
                return NO;
            }
        }
    }
    
    if (![upgrade isPlaceholder] && [upgrade isTalent] && [self.captain.externalId isEqualToString:@"lovok_72221a"]) {
        if (self.talentCount == 1) {
            if (![upgrade.title isEqualToString:@"Tal Shiar"]) {
                return NO;
            }
        } else {
            int talents = self.talentCount;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                        talents --;
                    }
                }
            }
            if (talents == 1 && ![upgrade.title isEqualToString:@"Tal Shiar"]) {
                if ([self containsUpgradeWithName:@"Tal Shiar"] == nil && validating) {
                    return NO;
                }
            } else if (talents < 1 && ![upgrade.title isEqualToString:@"Tal Shiar"]) {
                return NO;
            }
        }
    }
    
    if (![upgrade isPlaceholder] && [upgrade isTalent] && [self.captain.externalId isEqualToString:@"telek_r_mor_72016"]) {
        if (self.talentCount == 1) {
            if (![upgrade.title isEqualToString:@"Secret Research"]) {
                return NO;
            }
        } else {
            int talents = self.talentCount;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                        talents --;
                    }
                }
            }
            if (talents == 1 && ![upgrade.title isEqualToString:@"Secret Research"]) {
                if ([self containsUpgradeWithName:@"Secret Research"] == nil && validating) {
                    return NO;
                }
            } else if (talents < 1 && ![upgrade.title isEqualToString:@"Secret Research"]) {
                return NO;
            }
        }
    }
    
    if (![upgrade isPlaceholder] && [upgrade isTalent] && [self.captain.special isEqualToString:@"OnlyKlingonTalent"]) {
        if (self.talentCount == 1) {
            if (![upgrade isKlingon]) {
                return NO;
            }
        } else {
            int talents = self.talentCount;
            bool hasKT = NO;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                        talents --;
                        if ([eu.upgrade isKlingon]) {
                            hasKT = YES;
                        }
                    }
                }
            }
            if (talents == 1 && ![upgrade isKlingon]) {
                if (!hasKT && validating) {
                    return NO;
                }
            } else if (talents < 1 && ![upgrade isKlingon]) {
                return NO;
            }
        }
    }
    
    if (![upgrade isPlaceholder] && [upgrade isTalent] && [self.captain.special isEqualToString:@"TwoBajoranTalents"]) {
        if (self.talentCount == 2) {
            if (![upgrade isBajoran]) {
                return NO;
            }
        } else {
            int talents = self.talentCount;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                        talents --;
                    }
                }
            }
            if (talents <= 2 && ![upgrade isBajoran]) {
                return NO;
            } else if (talents < 1 && ![upgrade isBajoran]) {
                return NO;
            }
        }
    }
    
    if (![upgrade isPlaceholder] && [upgrade isTalent] && [self.captain.special isEqualToString:@"OneRomulanTalentDiscIfFleetHasRomulan"]) {
        if (self.talentCount == 1) {
            if (![upgrade isRomulan]) {
                return NO;
            }
        } else {
            int talents = self.talentCount;
            for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                    if ([eu.upgrade isTalent] && !eu.isPlaceholder) {
                        talents --;
                    }
                }
            }
            if (talents == 1 && ![upgrade isRomulan]) {
                if ([self upgradesWithSpecialTag:@"DiscRomTalent"].count == 0 && validating) {
                    return NO;
                }
            } else if (talents < 1 && ![upgrade isRomulan]) {
                return NO;
            }
        }
    }
    
    if (!upgrade.isPlaceholder && [upgrade isTech] && [self.captain.externalId isEqualToString:@"tahna_los_op6prize"]) {
        int tech = self.techCount;
        
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isTech] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"TahnaLosTech"]) {
                    tech --;
                }
            }
        }
        if (validating) {
            if (tech == 1 && [upgrade.special length] > 0) {
                if (![upgrade.special isEqualToString:@"NoMoreThanOnePerShip"] && ![upgrade.special isEqualToString:@"AddTwoWeaponSlots"] && ![upgrade.special hasSuffix:@"NoMoreThanOnePerShip"])
                return NO;
            }
        }
    }
    if (!upgrade.isPlaceholder && [upgrade isTech] && [self containsUpgradeWithId:@"quark_71786"] != nil) {
        int tech = self.techCount;
        
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isTech] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"QuarkTech"]) {
                    tech --;
                }
            }
        }
        if (validating) {
            if (tech == 1 && [upgrade costForShip:self] > 5) {
                return NO;
            }
        }
    }
    if (!upgrade.isPlaceholder && [upgrade isWeapon] && [self containsUpgradeWithId:@"quark_weapon_71786"] != nil) {
        int weapon = self.weaponCount;
        
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isWeapon] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"QuarkWeapon"]) {
                    weapon --;
                }
            }
        }
        if (validating) {
            if (weapon == 1 && [upgrade costForShip:self] > 5) {
                return NO;
            } else if ([upgrade.special isEqualToString:@"OnlyFedShipHV4CostPWVP1"]) {
                // This is stupid.
                return NO;
            } else if ([upgrade.special isEqualToString:@"OnlyFedShipHV4CostPWV"]) {
                // This is stupid.
                return NO;
            }
        }
    }
    if (!upgrade.isPlaceholder && [upgrade isWeapon] && [self containsUpgradeWithId:@"triphasic_emitter_71536"] != nil) {
        int weapon = self.weaponCount;
        
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isWeapon] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"HiddenWeaponTE"]) {
                    weapon --;
                }
            }
        }
        if (validating) {
            if (weapon == 1 && [upgrade costForShip:self] > 5) {
                return NO;
            } else if ([upgrade.special isEqualToString:@"OnlyFedShipHV4CostPWVP1"]) {
                // This is stupid.
                return NO;
            } else if ([upgrade.special isEqualToString:@"OnlyFedShipHV4CostPWV"]) {
                // This is stupid.
                return NO;
            }
        }
    }
    if (!upgrade.isPlaceholder && [upgrade isCrew] && [self containsUpgradeWithId:@"cryogenic_stasis_72009"] != nil) {
        int crew = self.crewCount;
        int cost = 0;
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isCrew] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"HiddenCrewCS"]) {
                    crew --;
                } else {
                    cost += eu.nonOverriddenCost;
                }
            }
        }
        if (validating) {
            if ((crew == 1 || crew == 2) && ([upgrade costForShip:self] + cost) > 5) {
                return NO;
            }
        }
    }
    if (!upgrade.isPlaceholder && [upgrade isCrew] && ([self containsUpgradeWithId:@"cargo_hold_20_72013"] != nil)) {
        int crew = self.crewCount;
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isCrew] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"CargoHoldCrew"]) {
                    crew --;
                }
            }
        }
        if (validating) {
            if ((crew == 1 || crew == 2) && [upgrade costForShip:self] > 4) {
                return NO;
            }
        }
    }
    if (!upgrade.isPlaceholder && [upgrade isTech] && [self containsUpgradeWithId:@"cargo_hold_02_72013"] != nil) {
        int tech = self.techCount;
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isTech] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"CargoHoldTech"]) {
                    tech --;
                }
            }
        }
        if (validating) {
            if ((tech == 1 || tech == 2) && [upgrade costForShip:self] > 4) {
                return NO;
            }
        }
    }
    if (!upgrade.isPlaceholder && ([upgrade isTech]||[upgrade isCrew]) && [self containsUpgradeWithId:@"cargo_hold_11_72013"] != nil) {
        int tech = self.techCount;
        int crew = self.crewCount;
        for (DockEquippedUpgrade* eu in self.upgrades) {
            if ([eu.upgrade isTech] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"CargoHoldTech"]) {
                    tech --;
                }
            }
            if ([eu.upgrade isCrew] && !eu.isPlaceholder) {
                if (![eu.specialTag hasPrefix:@"CargoHoldCrew"]) {
                    crew --;
                }
            }
        }
        if (validating) {
            if ([upgrade isTech] && (tech == 1 || tech == 2) && [upgrade costForShip:self] > 4) {
                return NO;
            }
            if ([upgrade isCrew] && (crew == 1 || crew == 2) && [upgrade costForShip:self] > 4) {
                return NO;
            }
        }
    }
    if ([upgrade isFleetCaptain]) {
        DockFleetCaptain* fleetCaptain = (DockFleetCaptain*)upgrade;
        return [self canAddFleetCaptain: fleetCaptain error: nil];
    }
    
    if ([upgrade isTalent]) {
        if ([captain.special isEqualToString: @"lore_71522"]) {
            return [upgrade isRestrictedOnlyByFaction];
        }
        if ([upgrade.special isEqualToString:@"OnlyBorgQueen"]) {
            if (![captain.title isEqualToString:@"Borg Queen"]) {
                return NO;
            }
        }
    }

    NSString* upgradeSpecial = upgrade.special;

    if ([upgrade isBorg]) {
        if ([self.ship isScoutCube]) {
            return [[upgrade cost] intValue] <= 5;
        }
    }
    
    if ([upgrade isWeapon] && ![upgrade.externalId isEqualToString:@"3007"]) {
        if ([self.ship isShuttle]) {
            if ( [self.ship.shipClass isEqualToString:@"Delta Flyer Class Shuttlecraft"]) {
                if ( [upgrade costForShip:self] > 4) {
                    return NO;
                }
            } else {
                if ([upgrade costForShip:self] > 3 ) {
                    return NO;
                }
            }
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyJemHadarShips"]) {
        if (![self.ship isJemhadar]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyTholianShip"]) {
        if (![self.ship isTholian]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyForKlingonCaptain"]) {
        if (![self.captain isKlingon]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyBajoranCaptain"]) {
        if (![self.captain isBajoran]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString: @"OnlyBajoranCaptainShip"]) {
        if (![self.captain isBajoran] || ![self.ship isBajoran]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString: @"OnlyBajoran"] || [upgradeSpecial isEqualToString: @"NoMoreThanOnePerShipBajoran"]) {
        if (![self.ship isBajoran]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString: @"OnlyBajoranFederation"]) {
        if (![self.ship isBajoran] && ![self.ship isFederation]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyDominionCaptain"]) {
        if (![self.captain isDominion]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyTholianCaptain"]) {
        if (![self.captain isTholian]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyBorgCaptain"]) {
        if (![captain isFactionBorg]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlySpecies8472Ship"] || [upgradeSpecial isEqualToString:@"NoMoreThanOnePerShipAndOnlySpecies8472Ship"]) {
        if (![self.ship isSpecies8472]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyKazonShip"]) {
        if (![self.ship isKazon]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString: @"OnlyKazonCaptainShip"]) {
        if (![self.ship isKazon] || ![self.captain isKazon]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyBorgShip"] || [upgradeSpecial isEqualToString: @"OnlyBorgShipAndNoMoreThanOnePerShip"]) {
        if (![self.ship isBorg]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyDderidexAndNoMoreThanOnePerShip"]) {
        if (![self.ship.shipClass isEqualToString:@"D'deridex Class"]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyFederationShip"] || [upgradeSpecial isEqualToString: @"ony_federation_ship_limited"] || [upgradeSpecial isEqualToString:@"ony_federation_ship_limited3"] || [upgradeSpecial isEqualToString:@"NoMoreThanOnePerShipFederation"] || [upgrade.externalId isEqualToString:@"dual_phaser_banks_72002p"]) {
        if (![self.ship isFederation]) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"OnlyFederationCaptainShip"]) {
        if (![self.ship isFederation]) {
            return NO;
        }
        if (![self.captain isFederation]) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString: @"only_vulcan_ship"]) {
        if (![self.ship isVulcan]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"only_suurok_class_limited_weapon_hull_plus_1"]) {
        if (![self.ship isSuurokClass]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyVoyager"]) {
        if (![self.ship isVoyager]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyFerengiShip"] || [upgradeSpecial isEqualToString:@"NoMoreThanOnePerShipFerengi"]) {
        if (![self.ship isFerengi]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyFerengiCaptainFerengiShip"]) {
        if (![self.ship isFerengi] || ![captain isFerengi]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyVulcanCaptainVulcanShip"]) {
        if (![self.ship isVulcan] || ![captain isVulcan]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyBattleshipOrCruiser"]) {
        if (![self.ship isBattleshipOrCruiser]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyNonBorgShipAndNonBorgCaptain"]) {
        if ([self.ship isBorg] || [captain isBorg]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"PhaserStrike"] || [upgradeSpecial isEqualToString: @"OnlyHull3OrLess"]) {
        if ([[self.ship hull] intValue] > 3) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString:@"OnlyRemanWarbird"]) {
        if (![self.ship isRemanWarbird]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"OnlyKlingonBirdOfPrey"]) {
        if (![self.ship isKlingonBirdOfPrey]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"OnlyRomulanShip"]) {
        if (![self.ship isRomulan]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString:@"OnlyRomulanCaptain"]) {
        if (![self.captain isRomulan]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString:@"OnlyRomulanCaptainShip"]) {
        if (![self.ship isRomulan] || ![self.captain isRomulan]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString:@"OnlyDominionShip"]) {
        if (![self.ship isDominion]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"ony_mu_ship_limited"]) {
        if (![self.ship isMirrorUniverse]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"ony_federation_ship_limited"] || [upgradeSpecial isEqualToString:@"ony_mu_ship_limited"]) {
        if ([self.ship.hull intValue] > 4) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"ony_federation_ship_limited3"]) {
        if ([self.ship.hull intValue] > 3) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"limited_max_weapon_3"] || [upgradeSpecial isEqualToString:@"limited_max_weapon_3AndPlus5NonFed"]) {
        if ([self.ship.attack intValue] > 3) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"OnlyDominionHV4"]) {
        if (![self.ship isDominion]) {
            return NO;
        }
        if ([self.ship.hull intValue] < 4) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"OnlyKlingon"]) {
        if (![self.ship isKlingon]) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"OnlyKlingonCaptainShip"]) {
        if (![self.ship isKlingon]) {
            return NO;
        }
        if (![self.captain isKlingon]) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"OnlyKlingonORRomulanCaptainShip"]) {
        if (![self.ship isKlingon] && ![self.ship isRomulan]) {
            return NO;
        }
        if (![self.captain isKlingon] && ![self.ship isRomulan]) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"OnlyXindiCaptainShip"]) {
        if (![self.ship isXindi]) {
            return NO;
        }
        if (![self.captain isXindi]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"OnlyIntrepidAndNoMoreThanOnePerShip"]) {
        if (![self.ship.shipClass isEqualToString:@"Intrepid Class"]) {
            return NO;
        }
    }
    
    if (![upgrade isPlaceholder] && [self containsUpgradeWithId:@"romulan_hijackers_71802"] != nil) {
        if ([upgrade isCaptain] || [upgrade isCrew]) {
            if (![upgrade isRomulan]) {
                return NO;
            }
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"NoMoreThanOnePerShipBajoranInterceptor"]) {
        if (![self.ship.shipClass isEqualToString:@"Bajoran Interceptor"]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"NoMoreThanOnePerShipBajoranScout"]) {
        if (![self.ship.shipClass isEqualToString:@"Bajoran Scout Ship"]) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"OnlyXindi"] || [upgradeSpecial isEqualToString:@"NoMoreThanOnePerShipAndOnlyXindi"] || [upgradeSpecial isEqualToString:@"OnlyXindiANDCostPWV"]) {
        if (![self.ship isXindi]) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"OnlyLBCaptain"]) {
        if (![self.captain.title isEqualToString:@"Lursa"] && ![self.captain.title isEqualToString:@"B'Etor"]) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"Hull4"] || [upgradeSpecial isEqualToString:@"OPSHull4"]) {
        if (self.hull < 4) {
            return NO;
        }
    }
    if ([upgradeSpecial isEqualToString:@"Hull3"] || [upgradeSpecial isEqualToString:@"OPSHull3"]) {
        if (self.hull < 3) {
            return NO;
        }
    }
    if (validating) {
        if ([upgradeSpecial isEqualToString: @"OnlyBorgShipAndNoMoreThanOnePerShip"] || [upgradeSpecial hasPrefix: @"NoMoreThanOnePerShip"] || [upgradeSpecial hasPrefix: @"ony_federation_ship_limited"] || [upgradeSpecial isEqualToString: @"only_suurok_class_limited_weapon_hull_plus_1"] || [upgradeSpecial isEqualToString:@"ony_mu_ship_limited"] || [upgradeSpecial isEqualToString:@"limited_max_weapon_3"] || [upgradeSpecial hasSuffix:@"NoMoreThanOnePerShip"] || [upgradeSpecial isEqualToString:@"limited_max_weapon_3AndPlus5NonFed"] || [upgradeSpecial hasPrefix:@"OPSOnlyShipClass_"] || [upgradeSpecial hasPrefix:@"OPSPlus"] || [upgradeSpecial hasPrefix:@"OPSHull"]) {
            DockEquippedUpgrade* existing = [self containsUpgradeWithId: upgrade.externalId];
            if (existing != nil) {
                return NO;
            } else if ([upgrade.externalId isEqualToString:@"systems_upgrade_71998p"]
                      || [upgrade.externalId isEqualToString:@"systems_upgrade_c_71998p"]
                      || [upgrade.externalId isEqualToString:@"systems_upgrade_w_71998p"]) {
                if ([self containsUpgradeWithId:@"systems_upgrade_71998p"] != nil
                    ||[self containsUpgradeWithId:@"systems_upgrade_c_71998p"] != nil
                    ||[self containsUpgradeWithId:@"systems_upgrade_w_71998p"] != nil) {
                    return NO;
                }
            } else if ([upgrade.externalId isEqualToString:@"unremarkable_species_72018"] || [upgrade.externalId isEqualToString:@"unremarkable_species_c_72018"] || [upgrade.externalId isEqualToString:@"unremarkable_species_t_72018"] || [upgrade.externalId isEqualToString:@"unremarkable_species_w_72018"]) {
                if ([self containsUpgradeWithId:@"unremarkable_species_72018"]  != nil || [self containsUpgradeWithId:@"unremarkable_species_c_72018"]  != nil || [self containsUpgradeWithId:@"unremarkable_species_t_72018"]  != nil || [self containsUpgradeWithId:@"unremarkable_species_w_72018"] != nil) {
                    return NO;
                }
            } else if ([upgrade.externalId isEqualToString:@"maintenance_crew_c_72022"] || [upgrade.externalId isEqualToString:@"maintenance_crew_t_72022"] || [upgrade.externalId isEqualToString:@"maintenance_crew_w_72022"]) {
                if ([self containsUpgradeWithId:@"maintenance_crew_c_72022"]  != nil || [self containsUpgradeWithId:@"maintenance_crew_t_72022"]  != nil || [self containsUpgradeWithId:@"maintenance_crew_w_72022"]  != nil) {
                    return NO;
                }
            } else if ([upgrade.externalId isEqualToString:@"auxiliary_control_room_t_72316p"] || [upgrade.externalId isEqualToString:@"auxiliary_control_room_w_72316p"]) {
                if ([self containsUpgradeWithId:@"auxiliary_control_room_t_72316p"]  != nil || [self containsUpgradeWithId:@"auxiliary_control_room_2_72316p"]  != nil) {
                    return NO;
                }
            } else if ([upgrade.externalId isEqualToString:@"automated_distress_beacon_c_72316p"] || [upgrade.externalId isEqualToString:@"automated_distress_beacon_t_72316p"] || [upgrade.externalId isEqualToString:@"automated_distress_beacon_w_72316p"]) {
                if ([self containsUpgradeWithId:@"automated_distress_beacon_c_72316p"]  != nil || [self containsUpgradeWithId:@"automated_distress_beacon_t_72316p"]  != nil || [self containsUpgradeWithId:@"automated_distress_beacon_w_72316p"]  != nil) {
                    return NO;
                }
            } else if ([upgrade.externalId isEqualToString:@"computer_core_c_72336"] || [upgrade.externalId isEqualToString:@"computer_core_w_72336"]) {
                if ([self containsUpgradeWithId:@"computer_core_c_72336"] != nil || [self containsUpgradeWithId:@"computer_core_w_72336"] != nil) {
                    return NO;
                }
            } else if ([upgrade.externalId isEqualToString:@"delta_shift_c_72320p"] || [upgrade.externalId isEqualToString:@"delta_shift_t_72320p"] || [upgrade.externalId isEqualToString:@"delta_shift_w_72320p"] || [upgrade.externalId isEqualToString:@"delta_shift_e_72320p"]) {
                if ([self containsUpgradeWithId:@"delta_shift_c_72320p"]  != nil || [self containsUpgradeWithId:@"delta_shift_t_72320p"]  != nil || [self containsUpgradeWithId:@"delta_shift_w_72320p"]  != nil || [self containsUpgradeWithId:@"delta_shift_e_72320p"] != nil) {
                    return NO;
                }
            } else if ([upgrade.externalId isEqualToString:@"change_course_c_72324p"] || [upgrade.externalId isEqualToString:@"change_course_e_72324p"] || [upgrade.externalId isEqualToString:@"change_course_t_72324p"] || [upgrade.externalId isEqualToString:@"change_course_w_72324p"]) {
                if ([self containsUpgradeWithId:@"change_course_c_72324p"]  != nil || [self containsUpgradeWithId:@"change_course_e_72324p"]  != nil || [self containsUpgradeWithId:@"change_course_t_72324p"]  != nil || [self containsUpgradeWithId:@"change_course_w_72324p"] != nil) {
                    return NO;
                }
            } else if ([upgrade.externalId isEqualToString:@"photon_detonation_t_72937"] || [upgrade.externalId isEqualToString:@"photon_detonation_w_72937"]) {
                if ([self containsUpgradeWithId:@"photon_detonation_t_72937"]  != nil || [self containsUpgradeWithId:@"photon_detonation_w_72937"] != nil) {
                    return NO;
                }
            }
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyForRomulanScienceVessel"] || [upgradeSpecial isEqualToString: @"OnlyForRaptorClassShips"]) {
        NSString* legalShipClass = upgrade.targetShipClass;

        if (![legalShipClass isEqualToString: self.ship.shipClass]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial hasPrefix:@"OnlyShip_"]) {
        NSString* shipTitle = [self.ship.title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"OnlyShip_%@",shipTitle]]) {
            return NO;
        }
    }

    if ([upgradeSpecial hasPrefix:@"OnlyShipClass_"]) {
        NSString* shipClass = [self.ship.shipClass stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if ([upgradeSpecial hasPrefix:@"OnlyShipClass_CONTAINS_"]) {
            NSString* classtomatch = [upgradeSpecial substringFromIndex:23];
            if ([shipClass rangeOfString:classtomatch].location == NSNotFound) {
                return NO;
            }
        } else if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"OnlyShipClass_%@",shipClass]]) {
            return NO;
        }
    }
    if ([upgradeSpecial hasPrefix:@"OPSOnlyShipClass_"]) {
        NSString* shipClass = [self.ship.shipClass stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if ([upgradeSpecial hasPrefix:@"OPSOnlyShipClass_CONTAINS_"]) {
            NSString* classtomatch = [upgradeSpecial substringFromIndex:26];
            if ([shipClass rangeOfString:classtomatch].location == NSNotFound) {
                return NO;
            }
        } else if (![upgradeSpecial isEqualToString:[NSString stringWithFormat:@"OPSOnlyShipClass_%@",shipClass]]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString: @"OnlyFedShipHV4CostPWVP1"]) {
        if ([self.ship isFederation]) {
            int shipHull = [self.ship.hull intValue];
            if (self.flagship != nil) {
                shipHull += self.flagship.hullAdd;
            }
            if (shipHull < 4) {
                return NO;
            }
        } else {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString: @"OnlyFedShipHV4CostPWV"]) {
        if ([self.ship isFederation]) {
            int shipHull = [self.ship.hull intValue];
            if (self.flagship != nil) {
                shipHull += self.flagship.hullAdd;
            }
            if (shipHull < 4) {
                return NO;
            }
        } else {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"Hull4NoRearPlus5NonFed"]) {
        int shipHull = [self.ship.hull intValue];
        if (self.flagship != nil) {
            shipHull += self.flagship.hullAdd;
        }
        if (shipHull < 4) {
            return NO;
        }
        if (![self.ship.shipClassDetails.rearArc isEqualToString:@""]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"MustHaveBS"]) {
        if (self.ship.battleStations.intValue == 0) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"PlusFiveNotKlingonAndMustHaveComeAbout"]) {
        if (self.ship.shipClassDetails.hasComeAbout == 0) {
            return NO;
        }
    }

    if ([self.ship.externalId isEqualToString:@"enterprise_nx_01_71526"] && [upgrade.upType isEqualToString: @"Tech"] && [self techCount] == 1 && [self containsUpgradeWithId:@"enhanced_hull_plating_71526"] != nil) {
            return NO;
    }

    if ([upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"] || [upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
        if ([self.ship isScoutCube]) {
            return NO;
        }
        int limit1 = [[DockUpgrade upgradeForId:@"biogenic_weapon_71510b" context:self.managedObjectContext] limitForShip:self];
        int limit2 = [[DockUpgrade upgradeForId:@"biogenic_weapon_borg_71510b" context:self.managedObjectContext] limitForShip:self];
        int limit = (limit1<limit2)? limit1 : limit2;
        
        if (validating) {
            if ([self containsUpgradeWithId:@"biogenic_weapon_71510b"] != nil && [self containsUpgradeWithId:@"biogenic_weapon_borg_71510b"] != nil) {
                int bwB = 0;
                int bwW = 0;
                for (DockEquippedUpgrade* eu in [self sortedUpgrades]) {
                    if ([eu.upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"]) {
                        bwW ++;
                    } else if ([eu.upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
                        bwB ++;
                    }
                }
                if (bwB == bwW) {
                    return limit > bwB;
                } else {
                    return NO;
                }
            } else {
                if ([upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"]) {
                    int borg = 0;
                    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                        if ([eu.upgrade.upType isEqualToString:@"Borg"] && !eu.isPlaceholder) {
                            borg ++;
                        }
                    }
                    return self.borgCount > borg;
                } else if ([upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
                    int weap = 0;
                    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
                        if ([eu.upgrade.upType isEqualToString:@"Weapon"] && !eu.isPlaceholder) {
                            weap ++;
                        }
                    }
                    return self.weaponCount > weap;
                }
            }
        }
        return limit > 0;
    }
    
    if ([upgrade.externalId isEqualToString:@"warp_drive_71997p"]) {
        if (![self.ship isFederation] || ![self.ship isShuttle]) {
            return NO;
        }
    }
    
    if ([upgrade.externalId isEqualToString:@"causality_paradox_71799"]) {
        if (![self.captain.externalId isEqualToString:@"annorax_71799"] && ![self.captain.externalId isEqualToString:@"krenim_71799"]) {
            return NO;
        }
    }
    
    if ([upgrade.externalId isEqualToString:@"unremarkable_species_72018"] || [upgrade.externalId isEqualToString:@"unremarkable_species_c_72018"] || [upgrade.externalId isEqualToString:@"unremarkable_species_t_72018"] || [upgrade.externalId isEqualToString:@"unremarkable_species_w_72018"]) {
        if ([self.ship isBorg]) {
            return NO;
        }
    }
    
    if ([upgradeSpecial isEqualToString:@"BSVT"]) {
        if ([self.squad containsUpgradeWithName:@"Borg Support Vehicle Dock"] == nil) {
            return NO;
        }
        if (self.hull > 7) {
            return NO;
        }
    }
    
    if ([upgrade.externalId isEqualToString:@"captains_chair_r_72936r"]) {
        if (![self.squad.resource.externalId isEqualToString:@"captains_chair_72936r"]) {
            return NO;
        }
        if ([self.captain.skill intValue] < 5) {
            return NO;
        }
    }
    
    if ([upgrade.externalId isEqualToString:@"front-line_retrofit_r_72941r"]) {
        if (![self.squad.resource.externalId isEqualToString:@"front-line_retrofit_72941r"]) {
            return NO;
        }
        if ([self.ship.hull intValue] > 3) {
            return NO;
        }
    }
    
    if ([upgrade.externalId isEqualToString:@"all_power_to_weapons_72946"]) {
        if ([[self.ship hull] intValue] < 5) {
            return NO;
        }
    }

    if (ignoreInstalled) {
        return YES;
    }

    int limit = [upgrade limitForShip: self];
    return limit > 0;
}

-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade
{
    return [self canAddUpgrade: upgrade ignoreInstalled: NO];
}

-(NSDictionary*)explainCantAddUpgrade:(DockUpgrade*)upgrade
{
    NSString* msg = [NSString stringWithFormat: @"Can't add %@ to %@", [upgrade plainDescription], [self plainDescription]];
    NSString* info = @"";
    if ([self isFighterSquadron]) {
        info = @"Fighter Squadrons cannot accept upgrades.";
    } else if ( self.ship.isScoutCube && [upgrade.cost intValue] >= 5 ) {
        info = @"You cannot deploy a [BORG] Upgrade with a cost greater than 5 to this ship.";
    } else if ([upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"]) {
        info = @"This is a special Elite Talent that can only be used by Shinzon.";
    } else {
        int limit = [upgrade limitForShip: self];
        
        if (limit == 0) {
            NSString* targetClass = [upgrade targetShipClass];
            
            if (targetClass != nil) {
                info = [NSString stringWithFormat: @"This upgrade can only be installed on ships of class %@.", targetClass];
            } else {
                if ([upgrade isTalent]) {
                    info = [NSString stringWithFormat: @"This ship's captain has no %@ upgrade symbols.", [upgrade.upType lowercaseString]];
                } else {
                    info = [NSString stringWithFormat: @"This ship has no %@ upgrade symbols on its ship card.", [upgrade.upType lowercaseString]];
                }
            }
        } else {
            NSString* upgradeSpecial = upgrade.special;
            if ([upgrade isTalent] && [self.captain.externalId isEqualToString:@"brunt_72013"] && ![upgrade.title isEqualToString:@"Grand Nagus"]) {
                info = @"Brunt may only deploy the Grand Nagus [TALENT].";
            } else if ([upgrade isTalent] && [self.captain.externalId isEqualToString:@"lovok_72221a"] && ![upgrade.title isEqualToString:@"Tal Shiar"]) {
                info = @"Lovok may only deploy the Tal Shiar [TALENT].";
            } else if ([upgrade.externalId isEqualToString:@"first_maje_71793"]) {
                info = @"This upgrade can only be purchased for a Kazon captain on a Kazon ship.";
            } else if ([upgrade isTalent] && [self.captain isKazon] && [self.ship isKazon] && self.talentCount == 1) {
                info = @"You can only deploy the First Maje [TALENT] to this captain.";
            } else if ([self containsUpgrade:upgrade] && ([upgradeSpecial hasPrefix: @"NoMoreThanOnePerShip"] || [upgradeSpecial isEqualToString: @"ony_federation_ship_limited"] || [upgradeSpecial isEqualToString: @"ony_mu_ship_limited"] || [upgradeSpecial isEqualToString: @"OnlyBorgShipAndNoMoreThanOnePerShip"] || [upgradeSpecial hasSuffix:@"NoMoreThanOnePerShip"] || [upgradeSpecial hasPrefix:@"OPSOnlyShipClass_"] || [upgradeSpecial hasPrefix:@"OPSPlus"] || [upgradeSpecial hasPrefix:@"OPSHull"])) {
                info = @"No ship may be equipped with more than one of these upgrades.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyJemHadarShips"]) {
                info = @"This upgrade can only be added to Jem'hadar ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyForKlingonCaptain"]) {
                info = @"This upgrade can only be added to a Klingon Captain.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyBajoranCaptain"]) {
                info = @"This upgrade can only be added to a Bajoran Captain.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyDominionCaptain"]) {
                info = @"This upgrade can only be added to a Dominion Captain.";
            } else if ([upgradeSpecial hasSuffix: @"OnlySpecies8472Ship"]) {
                info = @"This upgrade can only be added to Species 8472 ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyKazonShip"]) {
                info = @"This upgrade can only be added to Kazon ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyKazonCaptainShip"]) {
                info = @"This upgrade can only be added to a Kazon Captain on a Kazon ship.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyBorgShip"]) {
                info = @"This upgrade can only be added to Borg ships.";
            } else if ([upgradeSpecial isEqualToString: @"only_vulcan_ship"]) {
                info = @"This upgrade can only be added to Vulcan ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyFederationShip"]) {
                info = @"This upgrade can only be added to Federation ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyVoyager"]) {
                info = @"This upgrade can only be added to Voyager.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyTholianShip"]) {
                info = @"This upgrade can only be added to a Tholian ship.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyTholianCaptain"]) {
                info = @"This upgrade can only be added to a Tholian captain.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyBorgCaptain"]) {
                info = @"This upgrade may only be purchased for a Borg Captain.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyVulcanCaptainVulcanShip"]) {
                info = @"This upgrade can only be added to a Vulcan captain on a Vulcan ship.";
            } else if ([upgradeSpecial isEqualToString: @"PhaserStrike"] || [upgradeSpecial isEqualToString: @"OnlyHull3OrLess"]) {
                info = @"This upgrade may only be purchased for a ship with a Hull value of 3 or less.";
            } else if ([upgrade.externalId isEqualToString:@"warp_drive_71997p"]) {
                if ([self.ship isFederation] && [self.ship.shipClass isEqualToString:@"Type 7 Shuttlecraft"]) {
                    info = @"No ship may be equipped with more than one of these upgrades.";
                } else {
                    info = @"This upgrade may only be equipped by a Federation Shuttlecraft.";
                }
            } else if ([upgradeSpecial isEqualToString: @"OnlyBattleshipOrCruiser"]) {
                info = @"This upgrade may only be purchased for a Jem'Hadar Battle Cruiser or Battleship.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyFerengiShip"]) {
                info = @"This Upgrade may only be purchased for a Ferengi ship.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyFerengiCaptainFerengiShip"]) {
                info = @"This Upgrade may only be purchased for a Ferengi Captain assigned to a Ferengi ship.";
            } else if ([upgradeSpecial isEqualToString: @"not_with_hugh"]) {
                info = @"You cannot deploy this card to the same ship or fleet as Hugh.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyFedShipHV4CostPWVP1"] || [upgradeSpecial isEqualToString: @"OnlyFedShipHV4CostPWVP"]) {
                info = @"This Upgrade may only be purchased for a Federation ship with a Hull Value of 4 or greater.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyNonBorgShipAndNonBorgCaptain"]) {
                info = @"This Upgrade may only be purchased for a non-Borg ship with a non-Borg Captain.";
            } else if ([upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"] || [upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
                info = @"Biogenic Weapon requires 1 [BORG] and 1 [WEAPON] Upgrade slot.";
            } else if ([upgradeSpecial isEqualToString:@"OnlyRemanWarbird"]) {
                info = @"This Upgrade may only be purchased for a Reman Warbird";
            } else if ([upgradeSpecial isEqualToString:@"OnlyKlingonBirdOfPrey"]) {
                info = @"This Upgrade may only be purchased for a Klingon Bird-of-Prey";
            } else if ([upgrade isTech] && [self.captain.externalId isEqualToString:@"tahna_los_op6prize"]) {
                info = @"One of the [TECH] Upgrades you deploy to Tahna Los' ship cannot refer to a specific ship or class of ship.";
            } else if ([upgrade isTech] && [upgrade.cost intValue] > 5 && [self containsUpgradeWithId:@"quark_71786"] != nil) {
                info = @"You cannot deploy a [TECH] Upgrade with a cost greater than 5 to Quark.";
            } else if ([upgrade isWeapon] && [upgrade.cost intValue] > 5  && [self containsUpgradeWithId:@"quark_weapon_71786"] != nil) {
                info = @"You cannot deploy a [WEAPON] Upgrade with a cost greater than 5 to Quark.";
            } else if ([upgrade isWeapon] && [upgrade.cost intValue] > 5  && [self containsUpgradeWithId:@"triphasic_emitter_71536"] != nil) {
                info = @"You cannot deploy a [WEAPON] Upgrade with a cost greater than 5 to Triphasic Emitter.";
            } else if ([upgrade isWeapon] && [upgrade isFactionBorg] && [self containsUpgradeWithId:@"triphasic_emitter_71536"] != nil) {
                info = @"You cannot deploy a Borg [WEAPON] Upgrade to Triphasic Emitter.";
            } else if ([self.ship isShuttle] && [upgrade isWeapon] && [upgrade costForShip:self] > 3) {
                info = @"You cannot deploy a [WEAPON] Upgrade with a cost greater than 3 to a shuttlecraft.";
            } else if ([upgradeSpecial isEqualToString:@"OnlyKlingon"]) {
                info = @"This Upgrade may only be purchased for a Klingon ship.";
            } else if ([upgradeSpecial isEqualToString:@"OnlyKlingonCaptainShip"]) {
                info = @"This Upgrade may only be purchased for a Klingon Captain on a Klingon ship.";
            } else if ([upgradeSpecial isEqualToString:@"OnlyFederationCaptainShip"]) {
                info = @"This Upgrade may only be purchased for a Federation Captain on a Federation ship.";
            } else if ([self containsUpgradeWithId:@"romulan_hijackers_71802"] != nil && ![upgrade isRomulan] && [upgrade isCaptain]) {
                info = @"You may only deploy a Romulan Captain while this ship is equipped with the Romulan Hijackers Upgrade";
            } else if ([self containsUpgradeWithId:@"romulan_hijackers_71802"] != nil && ![upgrade isRomulan] && [upgrade isCrew]) {
                info = @"You may only deploy Romulan Crew Upgrades while this ship is equipped with the Romulan Hijackers Upgrade";
            } else if ([upgradeSpecial isEqualToString:@"limited_max_weapon_3"]) {
                info = @"You may only deploy this upgrade to a ship with a Primary Weapon Value of 3 or less.";
                if ([self containsUpgradeWithId:upgrade.externalId]) {
                    info = @"No ship may be equipped with more than one of these upgrades.";
                }
            } else if ([upgradeSpecial isEqualToString:@"limited_max_weapon_3AndPlus5NonFed"]) {
                info = @"You may only deploy this upgrade to a ship with a Primary Weapon Value of 3 or less.";
                if ([self containsUpgradeWithId:upgrade.externalId]) {
                    info = @"No ship may be equipped with more than one of these upgrades.";
                }
            } else if ([self containsUpgradeWithId:@"cargo_hold_11_72013"] != nil || [self containsUpgradeWithId:@"cargo_hold_20_72013"] != nil) {
                if ([upgrade isCrew] && [upgrade costForShip:self] > 4) {
                    info = @"You may only deploy [CREW] upgrades with a cost of 4 or less for Cargo Hold.";
                }
            } else if ([self containsUpgradeWithId:@"cargo_hold_11_72013"] != nil || [self containsUpgradeWithId:@"cargo_hold_02_72013"] != nil) {
                if ([upgrade isTech] && [upgrade costForShip:self] > 4) {
                    info = @"You may only deploy [TECH] upgrades with a cost of 4 or less for Cargo Hold.";
                }
            } else if ([upgradeSpecial isEqualToString:@"Hull4NoRearPlus5NonFed"]) {
                if ([self.ship.hull intValue] < 4) {
                    info = @"You may only deploy this upgrade to a ship with a Hull of 4 or greater.";
                } else if (![self.ship.shipClassDetails.rearArc isEqualToString:@""]) {
                    info = @"You may only deploy this upgrade to a ship without a rear firing arc.";
                }
            } else if ([upgradeSpecial isEqualToString:@"NoMoreThanOnePerShipBajoranInterceptor"]) {
                info = @"You may only deploy this upgrade to a Bajoran Interceptor";
            } else if ([upgradeSpecial isEqualToString:@"NoMoreThanOnePerShipBajoranScout"]) {
                info = @"You may only deploy this upgrade to a Bajoran Scout Ship";
            } else if ([upgradeSpecial isEqualToString:@"OnlyBajoranCaptainShip"]) {
                info = @"You may only deploy this upgrade to a Bajoran Captain assigned to a Bajoran Ship";
            } else if ([upgrade isTalent] && [self.captain.special isEqualToString:@"OnlyKlingonTalent"]) {
                info = @"This Captain may only field 1 Klingon [TALENT] Upgrade";
            } else if ([upgradeSpecial isEqualToString:@"OnlyBorgQueen"] && ![self.captain.title isEqualToString:@"Borg Queen"]) {
                info = @"This upgrade may only be assigned to the Borg Queen";
            } else if ([upgradeSpecial isEqualToString:@"BSVT"] && [self.squad containsUpgradeWithName:@"Borg Support Vehicle Dock"] == nil) {
                info = @"The Borg Support Vehicle Token may only be applied when a ship in your fleet is equipped with the Borg Support Vehicle Dock upgrade.";
            } else if ([upgradeSpecial isEqualToString:@"BSVT"] && self.hull > 7) {
                info = @"The Borg Support Vehicle Token may only be applied when a ship with a Hull Value of 7 or less.";
            } else if ([upgradeSpecial isEqualToString:@"Hull4"] && self.hull < 4) {
                info = @"This upgrade may only be assigned to a ship with a Hull Value of 4 or more.";
            } else if ([upgradeSpecial isEqualToString:@"Hull3"] && self.hull < 3) {
                info = @"This upgrade may only be assigned to a ship with a Hull Value of 3 or more.";
            } else if ([upgradeSpecial isEqualToString:@"OPSHull4"] && self.hull < 4) {
                info = @"This upgrade may only be assigned to a ship with a Hull Value of 4 or more.";
            } else if ([upgradeSpecial isEqualToString:@"OPSHull3"] && self.hull < 3) {
                info = @"This upgrade may only be assigned to a ship with a Hull Value of 3 or more.";
            } else if ([upgrade.externalId isEqualToString:@"captains_chair_r_72936r"] && [self.captain.skill intValue] < 5) {
                info = @"This resource may only be assigned to a ship with a Captain with a printed Captain Skill of 5 or higher.";
            } else if ([upgrade.externalId isEqualToString:@"front-line_retrofit_r_72941r"] && [self.ship.hull intValue] > 3) {
                info = @"This resource may only be assigned to a ship with a printed Hull Value of 3 or less.";
            }
        }
    }

    return @{
             @"info": info, @"message": msg
             };
}

-(BOOL)makeError:(NSError**)error msg:(NSString*)msg info:(NSString*)info
{
    if (error) {
        NSDictionary* d = @{
            NSLocalizedDescriptionKey: msg,
            NSLocalizedFailureReasonErrorKey: info
        };
        *error = [NSError errorWithDomain: DockErrorDomain code: kUniqueConflict userInfo: d];
        return NO;
    }
    return YES;
}

-(BOOL)canAddFleetCaptain:(DockFleetCaptain*)fleetCaptain error:(NSError**)error
{
    DockCaptain* captain = [self captain];
    NSString* msg = [NSString stringWithFormat: @"Can't make %@ the Fleet Captain.", captain.title];
    if ([captain.skill intValue] < 2) {
        NSString* info = @"You may not assign a non-unique Captain as your Fleet Captain.";
        [self makeError: error msg:msg info: info];
        return NO;
    }

    NSString* fleetCaptainFaction = fleetCaptain.faction;
    if (![fleetCaptainFaction isEqualToString: @"Independent"]) {
        if (!factionsMatch(self.ship, fleetCaptain)) {
            NSString* info = @"The ship's faction must be the same as the Fleet Captain.";
            [self makeError: error msg:msg info: info];
            return NO;
        }
        if (!factionsMatch(captain, fleetCaptain)) {
            NSString* info = @"The Captain's faction must be the same as the Fleet Captain.";
            [self makeError: error msg:msg info: info];
            return NO;
        }
    }

    return YES;
}

-(DockEquippedUpgrade*)addUpgradeInternal:(DockEquippedUpgrade *)equippedUpgrade
{
    [self willChangeValueForKey: @"cost"];
    [self addUpgrades: [NSSet setWithObject: equippedUpgrade]];
    [self didChangeValueForKey: @"cost"];
    return equippedUpgrade;
}

-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade maybeReplace:(DockEquippedUpgrade*)maybeReplace establishPlaceholders:(BOOL)establish
{
    return [self addUpgrade: upgrade maybeReplace: maybeReplace establishPlaceholders: establish respectLimits: YES];
}

-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade maybeReplace:(DockEquippedUpgrade*)maybeReplace establishPlaceholders:(BOOL)establish respectLimits:(BOOL)respectLimits
{
    NSManagedObjectContext* context = [self managedObjectContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"EquippedUpgrade"
                                              inManagedObjectContext: context];
    DockEquippedUpgrade* equippedUpgrade = [[DockEquippedUpgrade alloc] initWithEntity: entity
                                                        insertIntoManagedObjectContext: context];
    equippedUpgrade.upgrade = upgrade;

    if (establish && ![upgrade isPlaceholder]) {
        DockEquippedUpgrade* ph = [self findPlaceholder: upgrade.upType];

        if (ph) {
            [self removeUpgrade: ph];
        }
    }

    NSString* upType = [upgrade upType];
    int limit = [upgrade limitForShip: self];
    int current = [self equipped: upType];

    if (respectLimits && current == limit) {
        if (maybeReplace == nil || ![maybeReplace.upgrade.upType isEqualToString: upType]) {
            maybeReplace = [self firstUpgrade: upType];
        }

        [self removeUpgrade: maybeReplace establishPlaceholders: NO];
    }
    
    if ([upgrade isCaptain] && [self.ship.shipClass isEqualToString:@"Romulan Drone Ship"]) {
        if (![upgrade.externalId isEqualToString:@"gareb_71536"] && ![upgrade.externalId isEqualToString:@"romulan_drone_pilot_71536"] && ![upgrade.externalId isEqualToString:@"jhamel_72939"] && ![self.captain.externalId isEqualToString:@"gareb_71536"])
        {
            [self addUpgrade: [DockUpgrade upgradeForId:@"gareb_71536" context:context] maybeReplace: nil establishPlaceholders: NO];
        }
    }
    
    if ([upgrade.externalId isEqualToString:@"gareb_71536"]) {
        equippedUpgrade.specialTag = @" ";
    } else if ([upgrade isCaptain] && [self.captain.externalId isEqualToString:@"gareb_71536"]) {
        equippedUpgrade.specialTag = @"AdditionalCaptain";
    }

    [self addUpgradeInternal: equippedUpgrade];
    
    if (establish) {
        [self establishPlaceholders];
    }

    [[self squad] squadCompositionChanged];
    
    if ([upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"]) {
        int bwB = 0;
        int bwW = 0;
        for (DockEquippedUpgrade* eu in self.sortedUpgradesWithoutPlaceholders) {
            if ([eu.upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"]) {
                bwW ++;
            }
            if ([eu.upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
                bwB ++;
            }
        }
        if (bwB < bwW) {
            [self addUpgrade:[DockUpgrade upgradeForId:@"biogenic_weapon_borg_71510b" context:context]];
        }
    }
    
    if ([upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
        int bwB = 0;
        int bwW = 0;
        for (DockEquippedUpgrade* eu in self.sortedUpgradesWithoutPlaceholders) {
            if ([eu.upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"]) {
                bwW ++;
            }
            if ([eu.upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
                bwB ++;
            }
        }
        if (bwW < bwB) {
            [self addUpgrade:[DockUpgrade upgradeForId:@"biogenic_weapon_71510b" context:context]];
        }
        [equippedUpgrade overrideWithCost:0];
    }
    
    if (![upgrade isPlaceholder]) {
        if ([upgrade isTalent] && [upgrade isRomulan] && [self containsUpgradeWithId:@"shinzon_romulan_talents_71533"] != nil) {
            int romTalents = 0;
            for (DockEquippedUpgrade* eu in self.sortedUpgradesWithoutPlaceholders) {
                if (eu.upgrade.isTalent && [eu.upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"]) {
                    continue;
                } else if ([eu.specialTag hasPrefix:@"shinzon_ET_"]) {
                    romTalents ++;
                }
            }
            if (romTalents < 4 && ![upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"]) {
                equippedUpgrade.specialTag = [NSString stringWithFormat:@"shinzon_ET_%d",romTalents+1];
            }
        }
        if ([upgrade isTalent] && [upgrade isKlingon] && [self containsUpgradeWithId:@"dna_encoded_message_72938"] != nil) {
            int kliTalents = 0;
            for (DockEquippedUpgrade* eu in self.sortedUpgradesWithoutPlaceholders) {
                if (eu.upgrade.isTalent && [eu.upgrade.externalId isEqualToString:@"dna_encoded_message_72938"]) {
                    continue;
                } else if ([eu.specialTag hasPrefix:@"dna-enc_ET_"]) {
                    kliTalents ++;
                }
            }
            if (kliTalents < 3 && ![upgrade.externalId isEqualToString:@"dna_encoded_message_72938"]) {
                equippedUpgrade.specialTag = [NSString stringWithFormat:@"dna-enc_ET_%d",kliTalents+1];
            }
        }
        
        if ([upgrade isTech] && [upgrade isFederation] && [self containsUpgradeWithSpecial:@"Add3FedTech4Less"] != nil) {
            int fedTech = 0;
            for (DockEquippedUpgrade* eu in self.sortedUpgradesWithoutPlaceholders) {
                if ([eu.specialTag hasPrefix:@"fed3_tech_"]) {
                    fedTech ++;
                }
            }
            if (fedTech < 3) {
                equippedUpgrade.specialTag = [NSString stringWithFormat:@"fed3_tech_%d",fedTech+1];
            }
        }
        
        if ([upgrade isTech] && [upgrade isRomulan] && [self containsUpgradeWithSpecial:@"AddOneTechMinus1"] != nil) {
            int romTech = 0;
            for (DockEquippedUpgrade* eu in self.sortedUpgradesWithoutPlaceholders) {
                if ([eu.specialTag hasPrefix:@"nijil_tech_"]) {
                    romTech ++;
                }
            }
            if (romTech < 1) {
                int cost = [equippedUpgrade.upgrade costForShip:self];
                if (cost > 1) {
                    [equippedUpgrade overrideWithCost:cost - 1];
                }
                equippedUpgrade.specialTag = [NSString stringWithFormat:@"nijil_tech_%d",romTech+1];
            }
        }
        
        if ([upgrade isTech] && [self.captain.externalId isEqualToString:@"tahna_los_op6prize"]) {
            if ([self upgradesWithSpecialTag:@"TahnaLosTech"].count == 0) {
                if ([upgrade.special isEqualToString:@""] || [upgrade.special isEqualToString:@"NoMoreThanOnePerShip"] || [upgrade.special isEqualToString:@"AddTwoWeaponSlots"]) {
                    equippedUpgrade.specialTag = @"TahnaLosTech";
                    [equippedUpgrade overrideWithCost:3];
                }
            }
        }
        if ([upgrade isWeapon] && [self containsUpgradeWithId:@"quark_weapon_71786"] != nil && equippedUpgrade.cost <= 5) {
            if ([self upgradesWithSpecialTag:@"QuarkWeapon"].count == 0) {
                equippedUpgrade.specialTag = @"QuarkWeapon";
                [equippedUpgrade overrideWithCost:0];
            }
        }
        if ([upgrade isTech] && [self containsUpgradeWithId:@"quark_71786"] != nil && equippedUpgrade.cost <= 5) {
            if ([self upgradesWithSpecialTag:@"QuarkTech"].count == 0) {
                equippedUpgrade.specialTag = @"QuarkTech";
                [equippedUpgrade overrideWithCost:0];
            }
        }
        if ([upgrade isWeapon] && [self containsUpgradeWithId:@"triphasic_emitter_71536"] != nil && equippedUpgrade.cost <= 5 && ![upgrade.externalId isEqualToString:@"triphasic_emitter_71536"]) {
            if ([self upgradesWithSpecialTag:@"HiddenWeaponTE"].count < [self containsUpgradeWithIdCount:@"triphasic_emitter_71536"]) {
                equippedUpgrade.specialTag = @"HiddenWeaponTE";
                [equippedUpgrade overrideWithCost:0];
            }
        }
        if ([upgrade isCrew] && [self containsUpgradeWithId:@"cryogenic_stasis_72009"] != nil && equippedUpgrade.cost <= 5) {
            if ([self upgradesWithSpecialTag:@"HiddenCrewCS"].count < 2) {
                int cost = 0;
                for (DockEquippedUpgrade* eu in [self upgradesWithSpecialTag:@"HiddenCrewCS"]) {
                    cost += eu.nonOverriddenCost;
                }
                cost += equippedUpgrade.cost;
                if (cost <= 5) {
                    equippedUpgrade.specialTag = @"HiddenCrewCS";
                    [equippedUpgrade overrideWithCost:0];
                }
            }
        }

        
        if ([upgrade isCaptain] && [self.captain.externalId isEqualToString:@"gareb_71536"]) {
            int cost = equippedUpgrade.cost - 3;
            if (cost < 0) {
                cost = 0;
            }
            [self.equippedCaptain overrideWithCost:cost];
            [equippedUpgrade overrideWithCost:0];
        }
        
        if ([self.ship.externalId isEqualToString:@"sakharov_71997p"] && [upgrade isTech] && ![upgrade isPlaceholder]) {
            if ([self upgradesWithSpecialTag:@"SakhovBonus"].count == 0) {
                int cost = equippedUpgrade.cost - 2;
                if (cost < 0) {
                    cost = 0;
                }
                equippedUpgrade.specialTag = @"SakhovBonus";
                [equippedUpgrade overrideWithCost:cost];
            }

        }
        
        if ([self.ship.externalId isEqualToString:@"sakharov_c_71997p"] && [upgrade isCrew] && ![upgrade isPlaceholder]) {
            if ([self upgradesWithSpecialTag:@"SakhovBonus"].count == 0) {
                int cost = equippedUpgrade.cost - 2;
                if (cost < 0) {
                    cost = 0;
                }
                equippedUpgrade.specialTag = @"SakhovBonus";
                [equippedUpgrade overrideWithCost:cost];
            }
        }
        if ([upgrade isTalent] && [upgrade isRomulan] && [self.captain.special isEqualToString:@"OneRomulanTalentDiscIfFleetHasRomulan"]) {
            if ([self upgradesWithSpecialTag:@"DiscRomTalent"].count == 0) {
                BOOL rom = NO;
                for (DockEquippedShip* es in [self.squad equippedShips]) {
                    if (es != self) {
                        if ([es.ship isRomulan]) {
                            rom = YES;
                        }
                    }
                }
                if (rom) {
                    equippedUpgrade.specialTag = @"DiscRomTalent";
                    [equippedUpgrade overrideWithCost:equippedUpgrade.cost - 1];
                }
            }
        }
        if ([self.captain.externalId isEqualToString:@"khan_singh_72317p"] && equippedUpgrade.cost <= 6 && !equippedUpgrade.upgrade.isCaptain && !equippedUpgrade.upgrade.isAdmiral) {
            if ([self upgradesWithSpecialTag:@"KhanDiscounted"].count < 3) {
                equippedUpgrade.specialTag = @"KhanDiscounted";
                [equippedUpgrade overrideWithCost:4];
            }
        }
        if ([self upgradesWithSpecialTag:@"xindixtraweapon"].count == 0 && equippedUpgrade.upgrade.isWeapon && [self containsUpgradeWithSpecial:@"addoneweaponslot1xindi2less"] != nil) {
            equippedUpgrade.specialTag = @"xindixtraweapon";
            int thisCost = [equippedUpgrade cost];
            if (thisCost <= 2) {
                [equippedUpgrade overrideWithCost:0];
            } else {
                [equippedUpgrade overrideWithCost:thisCost-2];
            }
        }
    }
    if ([upgrade.externalId isEqualToString:@"romulan_hijackers_71802"]) {
        [self removeIllegalUpgrades];
    }
    
    return equippedUpgrade;
}

-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade maybeReplace:(DockEquippedUpgrade*)maybeReplace
{
    return [self addUpgrade: upgrade maybeReplace: maybeReplace establishPlaceholders: YES];
}

-(DockEquippedUpgrade*)firstUpgrade:(NSString*)upType
{
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([upType isEqualToString: eu.upgrade.upType]) {
            return eu;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)mostExpensiveUpgradeOfFaction:(NSString*)faction upType:(NSString*)upType
{
    DockEquippedUpgrade* mostExpensive = nil;
    NSArray* allUpgrades = [self allUpgradesOfFaction: faction upType: upType];

    if (allUpgrades.count > 0) {
        mostExpensive = allUpgrades[0];
    }

    return mostExpensive;
}

-(NSArray*)allUpgradesOfFaction:(NSString*)faction upType:(NSString*)upType
{
    NSMutableArray* allUpgrades = [[NSMutableArray alloc] init];

    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        if (![upgrade isCaptain] && ![upgrade isPlaceholder]) {
            if (upType == nil || [upType isEqualToString: upgrade.upType]) {
                if (faction == nil || [faction isEqualToString: upgrade.faction]) {
                    [allUpgrades addObject: eu];
                }
            }
        }
    }

    if (allUpgrades.count > 0) {
        if (allUpgrades.count > 1) {
            id cmp = ^(DockEquippedUpgrade* a, DockEquippedUpgrade* b) {
                int aCost = [a rawCost];
                int bCost = [b rawCost];

                if (aCost == bCost) {
                    return NSOrderedSame;
                } else if (aCost > bCost) {
                    return NSOrderedAscending;
                }

                return NSOrderedDescending;
            };
            [allUpgrades sortUsingComparator: cmp];
        }

    }

    return [NSArray arrayWithArray: allUpgrades];
}

-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade
{
    return [self addUpgrade: upgrade maybeReplace: nil];
}

-(void)removeUpgradeInternal:(DockEquippedUpgrade*)upgrade
{
    NSMutableSet* toRemove = [NSMutableSet setWithObject:upgrade];

    [self willChangeValueForKey: @"cost"];
    if ([upgrade.upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"])
    {
        for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
            if ([eu.upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
                [toRemove addObject:eu];
                break;
            }
        }
    } else if ([upgrade.upgrade.externalId isEqualToString:@"biogenic_weapon_borg_71510b"]) {
        for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
            if ([eu.upgrade.externalId isEqualToString:@"biogenic_weapon_71510b"]) {
                [toRemove addObject:eu];
                break;
            }
        }
    } else if ([upgrade.upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"]) {
        for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
            if ([eu.upgrade isRomulan] && [eu.specialTag hasPrefix:@"shinzon_ET_"])
            {
                [toRemove addObject:eu];
            }
        }
    } else if ([upgrade.upgrade.externalId isEqualToString:@"dna_encoded_message_72938"]) {
        for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
            if ([eu.upgrade isRomulan] && [eu.specialTag hasPrefix:@"dna-enc_ET_"])
            {
                [toRemove addObject:eu];
            }
        }
    } else if ([upgrade.upgrade.special isEqualToString:@"Add3FedTech4Less"]) {
        for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
            if ([eu.upgrade isFederation] && [eu.specialTag hasPrefix:@"fed3_tech_"])
            {
                [toRemove addObject:eu];
            }
        }
    } else if ([upgrade.upgrade.special isEqualToString:@"AddOneTechMinus1"]) {
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([eu.upgrade isRomulan] && [eu.specialTag hasPrefix:@"nijil_tech_"])
        {
            [toRemove addObject:eu];
        }
    }
}
    [self removeUpgrades: toRemove];
    [self didChangeValueForKey: @"cost"];
}

-(void)removeUpgrade:(DockEquippedUpgrade*)upgrade establishPlaceholders:(BOOL)doEstablish
{
    if (upgrade != nil) {
        [self removeUpgradeInternal: upgrade];

        if (doEstablish) {
            [self establishPlaceholders];
        }

        [self removeIllegalUpgrades];

        [[self squad] squadCompositionChanged];
    }
}

-(void)removeUpgrade:(DockEquippedUpgrade*)upgrade
{
    [self removeUpgrade: upgrade establishPlaceholders: NO];
}

-(void)removeUpgradesOfType:(NSString*)upType targetCount:(int)targetCount
{
    NSMutableArray* onesToRemove = [[NSMutableArray alloc] initWithCapacity: 0];

    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([eu.upgrade isPlaceholder] && [upType isEqualToString: eu.upgrade.upType]) {
            [onesToRemove addObject: eu];
        }

        if (onesToRemove.count == targetCount) {
            break;
        }
    }

    if (onesToRemove.count != targetCount) {
        for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
            if ([self.ship.externalId isEqualToString:@"enterprise_nx_01_71526"] && [eu.upgrade.externalId isEqualToString:@"enhanced_hull_plating_71526"]) {
                continue;
            }
            if ([upType isEqualToString: eu.upgrade.upType]) {
                [onesToRemove addObject: eu];
            }

            if (onesToRemove.count == targetCount) {
                break;
            }
        }
    }

    for (DockEquippedUpgrade* eu in onesToRemove) {
        [self removeUpgrade: eu establishPlaceholders: NO];
    }
}

-(void)removeIllegalUpgrades
{
    NSMutableArray* onesToRemove = [[NSMutableArray alloc] initWithCapacity: 0];
    int tecount = 0;
    int capcount = 0;
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([self.ship.externalId isEqualToString:@"enterprise_nx_01_71526"] && [eu.upgrade.externalId isEqualToString:@"enhanced_hull_plating_71526"]) {
            continue;
        }
        if ([eu.specialTag isEqualToString:@"SakhovBonus"]) {
            if ([self.ship.externalId isEqualToString:@"sakharov_71997p"] || [self.ship.externalId isEqualToString:@"sakharov_c_71997p"]) {
                if ([self upgradesWithSpecialTag:@"SakhovBonus"].count > 1) {
                    [eu removeCostOverride];
                    eu.specialTag = @"";
                }
                if ([eu.upgrade isTech] && ![self.ship.externalId isEqualToString:@"sakharov_71997p"]) {
                    [eu removeCostOverride];
                    eu.specialTag = @"";
                }
                if ([eu.upgrade isCrew] && ![self.ship.externalId isEqualToString:@"sakharov_c_71997p"]) {
                    [eu removeCostOverride];
                    eu.specialTag = @"";
                }
            } else {
                [eu removeCostOverride];
                eu.specialTag = @"";
            }
        }
        if (![self.captain.externalId isEqualToString:@"tahna_los_op6prize"] && [eu.specialTag isEqualToString:@"TahnaLosTech"]) {
            [onesToRemove addObject:eu];
        }
        
        if ([self containsUpgradeWithId:@"quark_71786"] == nil && [eu.specialTag isEqualToString:@"QuarkTech"]) {
            [onesToRemove addObject:eu];
        }
        if ([self containsUpgradeWithId:@"quark_weapon_71786"] == nil && [eu.specialTag isEqualToString:@"QuarkWeapon"]) {
            [onesToRemove addObject:eu];
        }
        if ([self containsUpgradeWithIdCount:@"triphasic_emitter_71536"] > ([self upgradesWithSpecialTag:@"HiddenWeaponTE"].count + tecount) && [eu.specialTag isEqualToString:@"HiddenWeaponTE"]) {
            [onesToRemove addObject:eu];
            tecount ++;
        }
        if (![self.captain.externalId isEqualToString:@"khan_singh_72317p"] && [eu.specialTag isEqualToString:@"KhanDiscounted"]) {
            [onesToRemove addObject:eu];
        }
        if ([eu.upgrade isCaptain]) {
            capcount ++;
        }
        if (capcount > self.captainCount) {
            [onesToRemove addObject:eu];
        }
        if (![self canAddUpgrade: eu.upgrade ignoreInstalled: NO validating: NO]) {
            [onesToRemove addObject: eu];
        }
    }

    for (DockEquippedUpgrade* eu in onesToRemove) {
        [self removeUpgrade: eu establishPlaceholders: YES];
    }
}

-(NSArray*)sortedUpgrades
{
    NSArray* items = [self.upgrades allObjects];
    return [items sortedArrayUsingComparator: ^(DockEquippedUpgrade* a, DockEquippedUpgrade* b) {
                return [a compareTo: b];
            }

    ];
}

-(NSArray*)sortedUpgradesWithFlagship
{
    NSArray* items = [self.upgrades allObjects];
#if !TARGET_OS_IPHONE
    if (self.flagship) {
        DockEquippedFlagship* efs = [DockEquippedFlagship equippedFlagship: self.flagship forShip: self];
        items = [@[efs] arrayByAddingObjectsFromArray: items];
    }
#endif
    return [items sortedArrayUsingComparator: ^(DockEquippedUpgrade* a, DockEquippedUpgrade* b) {
                return [a compareTo: b];
            }

    ];
}

-(NSArray*)sortedUpgradesWithoutPlaceholders
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity: 0];
    NSArray* sortedUpgrades = [self sortedUpgrades];
    for (DockUpgrade* upgrade in sortedUpgrades) {
        if (!upgrade.isPlaceholder && !upgrade.isCaptain) {
            [result addObject: upgrade];
        }
    }
    return [NSArray arrayWithArray: result];
}

-(void)removeCaptain
{
    [self removeUpgrade: [self equippedCaptain]];
}

-(int)talentCount
{
    int talentCount = 0;
    talentCount += [self.flagship talentAdd];
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        talentCount += [upgrade additionalTalentSlots];
        if ([upgrade.externalId isEqualToString:@"shinzon_romulan_talents_71533"]) {
            talentCount += 4;
        }
        if ([upgrade.externalId isEqualToString:@"dna_encoded_message_72938"]) {
            talentCount += 3;
        }
    }
    if ([self.captain isKazon] && [self.ship isKazon]) {
        talentCount ++;
    }
    if ([self.captain.externalId isEqualToString:@"slar_71797"] || [self.captain.externalId isEqualToString:@"kurn_71999p"] || [self.captain.externalId isEqualToString:@"brunt_72013"] || [self.captain.externalId isEqualToString:@"lovok_72221a"] || [self.captain.externalId isEqualToString:@"telek_r_mor_72016"]) {
        talentCount ++;
    }
    if ([self.captain.special isEqualToString:@"OneRomulanTalentDiscIfFleetHasRomulan"]) {
        BOOL rom = NO;
        for (DockEquippedShip* es in [self.squad equippedShips]) {
            if (es != self) {
                if ([es.ship isRomulan]) {
                    rom = YES;
                }
            }
        }
        if (rom) {
            talentCount ++;
        }
    }
    if ([self.captain.special isEqualToString:@"TwoBajoranTalents"]) {
        talentCount += 2;
    }
    return talentCount;

#if 0
    DockCaptain* captain = [self captain];
    int talentCount = [captain talentCount];
    DockAdmiral* admiral = [self admiral];
    talentCount += admiral.admiralTalentCount;
    talentCount += [self.flagship talentAdd];
    return talentCount;
#endif
}

-(int)shipPropertyCount:(NSString*)propertyName
{
    return [[self.ship valueForKey: propertyName] intValue];
}

-(int)techCount
{
    int techCount = [self shipPropertyCount: @"tech"];
    techCount += [self.flagship techAdd];
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        techCount += [upgrade additionalTechSlots];
        if ([self.ship.externalId isEqualToString:@"enterprise_nx_01_71526"] && [upgrade.externalId isEqualToString:@"enhanced_hull_plating_71526"] && ![eu.specialTag isEqualToString:@"AdditionalCaptain"]) {
            techCount ++;
        }
    }

    return techCount;
}

-(int)weaponCount
{
    int weaponCount = [self shipPropertyCount: @"weapon"];
    weaponCount += [self.flagship weaponAdd];

    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        if (![eu.specialTag isEqualToString:@"AdditionalCaptain"]) {
            weaponCount += [upgrade additionalWeaponSlots];
        }
    }

    return weaponCount;
}

-(int)crewCount
{
    int crewCount = [self shipPropertyCount: @"crew"];
    crewCount += [self.flagship crewAdd];
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        if (![eu.specialTag isEqualToString:@"AdditionalCaptain"]) {
            crewCount += [upgrade additionalCrewSlots];
        }
    }

    if ([[self.captain special] isEqualToString:@"RemanBodyguardsLess2"]) {
        if (crewCount == 0) {
            crewCount ++;
        } else {
            if ([self containsUpgradeWithName:@"Reman Bodyguards"] != nil) {
                crewCount ++;
            }
        }
    }
    return crewCount;
}

-(int)upgradeCount
{
    int count = 0;

    for (DockEquippedUpgrade* eu in[self sortedUpgrades]) {
        DockUpgrade* upgrade = eu.upgrade;

        if (![upgrade isPlaceholder] && ![upgrade isCaptain]) {
            count += 1;
        }
    }
    return count;
}

-(int)captainCount
{
    if ([self.captain.externalId isEqualToString:@"gareb_71536"])
    {
        return 2;
    }
    if ([self.squad.resource.externalId isEqualToString:@"fleet_commander_72323r"]) {
        int capCount = 0;
        for (DockEquippedShip *ship in self.squad.equippedShips) {
            if (ship != self) {
                for (DockEquippedUpgrade *cap in [ship upgrades]) {
                    if (![cap.upgrade isPlaceholder]) {
                        if ([cap.upgrade isCaptain]) {
                            capCount ++;
                        }
                    }
                }
                if (capCount > 1) {
                    break;
                } else {
                    capCount = 0;
                }
            }
        }
        return (capCount>1)? 1 : 2;
    }
    return self.ship.captainCount;
}

-(int)admiralCount
{
    return self.ship.admiralCount;
}

-(int)fleetCaptainCount
{
    return self.ship.fleetCaptainCount;
}

-(int)borgCount
{
    int borgCount = self.ship.borgCount;
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        if (![eu.specialTag isEqualToString:@"AdditionalCaptain"]) {
            borgCount += [upgrade additionalBorgSlots];
        }
    }
    return borgCount;
}

-(int)squadronUpgradeCount
{
    int squadronUpgradeCount = self.ship.squadronUpgradeCount;
    
    return squadronUpgradeCount;
}

-(int)resourceUpgradeCount
{
    if ([self.squad.resource.externalId isEqualToString:@"captains_chair_72936r"]) {
        if ([self.squad containsUpgrade:[DockUpgrade upgradeForId:@"captains_chair_r_72936r" context:self.managedObjectContext]] == nil) {
            return 1;
        }
    }
    if ([self.squad.resource.externalId isEqualToString:@"front-line_retrofit_72941r"]) {
        if ([self.squad containsUpgrade:[DockUpgrade upgradeForId:@"front-line_retrofit_r_72941r" context:self.managedObjectContext]] == nil) {
            return 1;
        }
    }
    return 0;
}

-(int)officerLimit
{
    NSArray* crewUpgrades = [self allUpgradesOfFaction: nil upType: @"Crew"];
    NSInteger limit = crewUpgrades.count * 2;
    return (int)limit;
}

-(NSString*)ability
{
    return self.ship.ability;
}

-(DockEquippedUpgrade*)containsUpgrade:(DockUpgrade*)theUpgrade
{
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if (eu.upgrade == theUpgrade) {
            return eu;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)containsUpgradeWithName:(NSString*)theName
{
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([eu.upgrade.title isEqualToString: theName]) {
            return eu;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)containsUniqueUpgradeWithName:(NSString*)theName
{
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        if (upgrade.isUnique && [upgrade.title isEqualToString: theName]) {
            return eu;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)containsMirrorUniverseUniqueUpgradeWithName:(NSString*)theName
{
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        if (upgrade.isMirrorUniverseUnique && [upgrade.title isEqualToString: theName]) {
            return eu;
        }
    }
    return nil;
}


-(DockEquippedUpgrade*)containsUpgradeWithSpecial:(NSString*)special
{
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([eu.upgrade.special isEqualToString: special]) {
            return eu;
        }
    }
    return nil;
}

-(NSArray*)upgradesWithSpecialTag:(NSString*)specialTag
{
    NSMutableArray* taggedUpgrades = [[NSMutableArray alloc] initWithCapacity: 0];
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([eu.specialTag isEqualToString:specialTag]) {
            [taggedUpgrades addObject:eu];
        }
    }
    return taggedUpgrades;
}

-(DockEquippedUpgrade*)containsUpgradeWithId:(NSString*)theId
{
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([eu.upgrade.externalId isEqualToString: theId]) {
            return eu;
        }
    }
    return nil;
}

-(NSUInteger)containsUpgradeWithIdCount:(NSString*)theId
{
    int count = 0;
    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if ([eu.upgrade.externalId isEqualToString: theId]) {
            count ++;
        }
    }
    return count;
}


-(void)changeShip:(DockShip*)newShip
{
    if ([self.ship.externalId isEqualToString:@"enterprise_nx_01_71526"]) {
        for(DockEquippedUpgrade* upg in self.upgrades) {
            if ([upg.upgrade.externalId isEqualToString:@"enhanced_hull_plating_71526"]) {
                [self removeUpgrade:upg];
                break;
            }
        }
    }
    BOOL wasFighter = [self isFighterSquadron];
    self.ship = newShip;
    [self removeIllegalUpgrades];
    [self establishPlaceholders];
    if (wasFighter) {
        self.squad.resource = nil;
    } else if (newShip.isFighterSquadron) {
        self.squad.resource = newShip.associatedResource;
    }
    
    if ([newShip.externalId isEqualToString:@"enterprise_nx_01_71526"]) {
        [self addUpgrade:[DockUpgrade upgradeForId:@"enhanced_hull_plating_71526" context:self.managedObjectContext]];
    }
}

-(NSDictionary*)becomeFlagship:(DockFlagship*)flagship
{
    if (![flagship compatibleWithShip: self.ship]) {
        if (self.ship.isFighterSquadron) {
            NSString* msg = [NSString stringWithFormat: @"Can't add %@ to %@", [flagship plainDescription], [self.ship plainDescription]];
            NSString* info = @"It is illogical to try to make a figher squadron into a flagship.";
            return @{@"info": info, @"message": msg};
        }
        NSString* msg = [NSString stringWithFormat: @"Can't add %@ to %@", [flagship plainDescription], [self.ship plainDescription]];
        NSString* info = @"The faction of the flagship must be independent or match the faction of the target ship.";
        return @{@"info": info, @"message": msg};
    }
    if (self.flagship != flagship) {
        for (DockEquippedShip* equippedShip in self.squad.equippedShips) {
            if (equippedShip != self) {
                [equippedShip removeFlagship];
            }
        }
        self.flagship = flagship;
        self.squad.resource = [DockResource flagshipResource: self.managedObjectContext];
        [self establishPlaceholders];
    }
    
    return nil;
}

-(void)removeFlagship
{
    if (self.flagship != nil) {
        self.flagship = nil;
        [self establishPlaceholders];
    }
}

-(void)handleNewInsertedOrReplaced:(NSDictionary*)change
{
    NSArray* newInsertedOrReplaced = [change objectForKey: NSKeyValueChangeNewKey];
    if (newInsertedOrReplaced != (NSArray*)[NSNull null]) {
        for (DockEquippedUpgrade* upgrade in newInsertedOrReplaced) {
            [upgrade addObserver: self forKeyPath: @"cost" options: 0 context: 0];
        }
    }
}

-(void)handleOldRemovedOrReplaced:(NSDictionary*)change
{
    NSArray* oldRemovedOrReplaced = [change objectForKey: NSKeyValueChangeOldKey];
    if (oldRemovedOrReplaced != (NSArray*)[NSNull null]) {
        for (DockEquippedUpgrade* upgrade in oldRemovedOrReplaced) {
            [upgrade removeObserver: self forKeyPath: @"cost"];
        }
    }
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (![self isFault]) {
        if ([keyPath isEqualToString: @"cost"]) {
            [self willChangeValueForKey: @"cost"];
            [self didChangeValueForKey: @"cost"];
        } else {
            NSUInteger kind = [[change valueForKey: NSKeyValueChangeKindKey] integerValue];
            switch (kind) {
            case NSKeyValueChangeInsertion:
                [self handleNewInsertedOrReplaced: change];
                break;
            case NSKeyValueChangeRemoval:
                [self handleOldRemovedOrReplaced: change];
                break;
            case NSKeyValueChangeSetting:
                [self handleNewInsertedOrReplaced: change];
                [self handleOldRemovedOrReplaced: change];
                break;
            default:
                NSLog(@"unhandled kind in observeValueForKeyPath: %@", change);
                break;
            }
        }
    }
}

-(void)watchForCostChange
{
    for (DockEquippedUpgrade* upgrade in self.upgrades) {
        [upgrade addObserver: self forKeyPath: @"cost" options: 0 context: 0];
    }
    [self addObserver: self forKeyPath: @"upgrades" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context: 0];
}

-(void)stopWatchingForCostChange
{
    for (DockEquippedUpgrade* upgrade in self.upgrades) {
        [upgrade removeObserver: self forKeyPath: @"cost"];
    }
    [self removeObserver: self forKeyPath: @"upgrades"];
}

-(void)awakeFromInsert
{
    [super awakeFromInsert];
    [self watchForCostChange];
}

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    [self watchForCostChange];
}

- (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags
{
    [super awakeFromSnapshotEvents: flags];
    [self watchForCostChange];
}

- (void)willTurnIntoFault
{
    [self stopWatchingForCostChange];
}

-(void)willSave
{
    [self.squad updateModificationDate];
}

-(DockEquippedUpgrade*)addAdmiral:(DockAdmiral*)admiral
{
    [self removeAdmiral];
    return [self addUpgrade: admiral];
}

-(void)removeAdmiral
{
    DockEquippedUpgrade* admiral = [self equippedAdmiral];
    if (admiral != nil) {
        [self removeUpgrade: admiral];
    }
}

-(DockEquippedUpgrade*)equippedAdmiral
{
    if (self.ship.isFighterSquadron) {
        return nil;
    }
    
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;

        if ([upgrade.upType isEqualToString: kAdmiralUpgradeType]) {
            return eu;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)equippedFleetCaptain
{
    if (self.ship.isFighterSquadron) {
        return nil;
    }
    
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;

        if ([upgrade.upType isEqualToString: kFleetCaptainUpgradeType]) {
            return eu;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)equippedResource
{

    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        
        if ([upgrade.upType isEqualToString:@"Resource"]) {
            return eu;
        }
    }
    return nil;
}

-(void)purgeUpgrade:(DockUpgrade*)upgrade
{
    NSMutableSet* onesToRemove = [NSMutableSet setWithCapacity: 0];

    for (DockEquippedUpgrade* eu in self.upgrades) {
        if (eu.upgrade == upgrade) {
            [onesToRemove addObject: eu];
        }
    }

    for (DockEquippedUpgrade* eu in onesToRemove) {
        [self removeUpgradeInternal: eu];
    }
    
    [self establishPlaceholders];
}

@end
