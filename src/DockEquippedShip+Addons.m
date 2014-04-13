#import "DockEquippedShip+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockEquippedUpgrade.h"
#import "DockEquippedFlagship.h"
#import "DockFlagship+Addons.h"
#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
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
    if (self.flagship != nil) {
        s = [s stringByAppendingString: @" [FS]"];
    }
    return s;
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
        [json setObject: [NSNumber numberWithInt: self.cost] forKey: @"calculatedCost"];
        DockFlagship* flagship = self.flagship;
        if (flagship != nil) {
            [json setObject: flagship.externalId forKey: @"flagship"];
        }
    }
    [json setObject: [self.equippedCaptain asJSON]  forKey: @"captain"];
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

-(NSString*)factionCode
{
    return factionCode(self.ship);
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
    return [self.ship.attack intValue] + [self.flagship attackAdd];
}

-(int)agility
{
    return [self.ship.agility intValue] + [self.flagship agilityAdd];
}

-(int)hull
{
    return [self.ship.hull intValue] + [self.flagship hullAdd];
}

-(int)shield
{
    return [self.ship.shield intValue] + [self.flagship shieldAdd];
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
            return eu;
        }
    }
    return nil;
}

-(DockCaptain*)captain
{
    return (DockCaptain*)[[self equippedCaptain] upgrade];
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
    NSManagedObjectContext* context = self.managedObjectContext;
    NSDictionary* upgradeDict = esDict[@"captain"];
    NSString* captainId = upgradeDict[@"upgradeId"];
    [self addUpgrade: [DockCaptain captainForId: captainId context: context]];
    NSArray* upgrades = esDict[@"upgrades"];
    for (upgradeDict in upgrades) {
        NSString* upgradeId = upgradeDict[@"upgradeId"];
        DockUpgrade* upgrade = [DockUpgrade upgradeForId: upgradeId context: context];
        DockEquippedUpgrade* eu = [self addUpgrade: upgrade];
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
    } else {
        newShip = [DockEquippedShip equippedShipWithShip: self.ship];
        newShip.flagship = self.flagship;
    }

    for (DockEquippedUpgrade* equippedUpgrade in self.sortedUpgrades) {
        DockUpgrade* upgrade = [equippedUpgrade upgrade];

        if (![upgrade isPlaceholder]) {
            DockEquippedUpgrade* duppedUpgrade = [newShip addUpgrade: equippedUpgrade.upgrade maybeReplace: nil establishPlaceholders: NO];
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

            DockUpgrade* zcc = [DockCaptain zeroCostCaptain: faction context: self.managedObjectContext];
            [self addUpgrade: zcc maybeReplace: nil establishPlaceholders: NO];
        }
    }

    [self establishPlaceholdersForType: @"Talent" limit: self.talentCount];
    [self establishPlaceholdersForType: @"Crew" limit: self.crewCount];
    [self establishPlaceholdersForType: @"Weapon" limit: self.weaponCount];
    [self establishPlaceholdersForType: @"Tech" limit: self.techCount];
    [self establishPlaceholdersForType: @"Borg" limit: self.borgCount];
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

-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade
{
    NSString* upgradeSpecial = upgrade.special;

    if ([upgradeSpecial isEqualToString: @"OnlyJemHadarShips"]) {
        if (![self.ship isJemhadar]) {
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

    if ([upgradeSpecial isEqualToString: @"OnlySpecies8472Ship"]) {
        if (![self.ship isSpecies8472]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyKazonShip"]) {
        if (![self.ship isKazon]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyBorgShip"]) {
        if (![self.ship isBorg]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyVoyager"]) {
        if (![self.ship isVoyager]) {
            return NO;
        }
    }

    if ([upgradeSpecial isEqualToString: @"OnlyForRomulanScienceVessel"] || [upgradeSpecial isEqualToString: @"OnlyForRaptorClassShips"]) {
        NSString* legalShipClass = upgrade.targetShipClass;

        if (![legalShipClass isEqualToString: self.ship.shipClass]) {
            return NO;
        }
    }

    int limit = [upgrade limitForShip: self];
    return limit > 0;
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
    NSManagedObjectContext* context = [self managedObjectContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"EquippedUpgrade"
                                              inManagedObjectContext: context];
    DockEquippedUpgrade* equippedUpgrade = [[DockEquippedUpgrade alloc] initWithEntity: entity
                                                        insertIntoManagedObjectContext: context];
    equippedUpgrade.upgrade = upgrade;

    if (![upgrade isPlaceholder]) {
        DockEquippedUpgrade* ph = [self findPlaceholder: upgrade.upType];

        if (ph) {
            [self removeUpgrade: ph];
        }
    }

    NSString* upType = [upgrade upType];
    int limit = [upgrade limitForShip: self];
    int current = [self equipped: upType];

    if (current == limit) {
        if (maybeReplace == nil) {
            maybeReplace = [self firstUpgrade: upType];
        }

        [self removeUpgrade: maybeReplace establishPlaceholders: NO];
    }

    [self addUpgradeInternal: equippedUpgrade];

    if (establish) {
        [self establishPlaceholders];
    }

    [[self squad] squadCompositionChanged];
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
        if (![upgrade isCaptain]) {
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
    [self willChangeValueForKey: @"cost"];
    [self removeUpgrades: [NSSet setWithObject: upgrade]];
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

    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if (![self canAddUpgrade: eu.upgrade]) {
            [onesToRemove addObject: eu];
        }
    }

    for (DockEquippedUpgrade* eu in onesToRemove) {
        [self removeUpgrade: eu establishPlaceholders: NO];
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

-(void)removeCaptain
{
    [self removeUpgrade: [self equippedCaptain]];
}

-(int)talentCount
{
    DockCaptain* captain = [self captain];
    int talentCount = [captain talentCount];
    talentCount += [self.flagship talentAdd];
    return talentCount;
}

-(int)shipPropertyCount:(NSString*)propertyName
{
    return [[self.ship valueForKey: propertyName] intValue];
}

-(int)techCount
{
    int techCount = [self shipPropertyCount: @"tech"];
    techCount += [self.captain additionalTechSlots];
    techCount += [self.flagship techAdd];
    return techCount;
}

-(int)weaponCount
{
    int weaponCount = [self shipPropertyCount: @"weapon"];
    weaponCount += [self.flagship weaponAdd];

    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        weaponCount += [upgrade additionalWeaponSlots];
    }

    return weaponCount;
}

-(int)crewCount
{
    int crewCount = [self shipPropertyCount: @"crew"];
    crewCount += [self.flagship crewAdd];
    crewCount += [self.captain additionalCrewSlots];
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
    return self.ship.captainCount;
}

-(int)borgCount
{
    return self.ship.borgCount;
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

-(void)changeShip:(DockShip*)newShip
{
    self.ship = newShip;
    [self removeIllegalUpgrades];
    [self establishPlaceholders];
    if (self.squad.resource.isFighterSquadron) {
        self.squad.resource = nil;
    } else if (newShip.isFighterSquadron) {
        self.squad.resource = newShip.associatedResource;
    }
}

-(NSDictionary*)explainCantAddUpgrade:(DockUpgrade*)upgrade
{
    NSString* msg = [NSString stringWithFormat: @"Can't add %@ to %@", [upgrade plainDescription], [self plainDescription]];
    NSString* info = @"";
    if ([self isFighterSquadron]) {
        info = @"Fighter Squadrons cannot accept upgrades.";
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
            
            if ([upgradeSpecial isEqualToString: @"OnlyJemHadarShips"]) {
                info = @"This upgrade can only be added to Jem'hadar ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyForKlingonCaptain"]) {
                info = @"This upgrade can only be added to a Klingon Captain.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyBajoranCaptain"]) {
                info = @"This upgrade can only be added to a Bajoran Captain.";
            } else if ([upgradeSpecial isEqualToString: @"OnlySpecies8472Ship"]) {
                info = @"This upgrade can only be added to Species 8472 ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyKazonShip"]) {
                info = @"This upgrade can only be added to Kazon ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyBorgShip"]) {
                info = @"This upgrade can only be added to Borg ships.";
            } else if ([upgradeSpecial isEqualToString: @"OnlyVoyager"]) {
                info = @"This upgrade can only be added to Voyager.";
            }
        }
    }
    
    return @{
             @"info": info, @"message": msg
             };
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
}

@end
