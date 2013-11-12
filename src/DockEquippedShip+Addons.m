#import "DockEquippedShip+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockEquippedUpgrade.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockEquippedShip (Addons)

+(NSSet*)keyPathsForValuesAffectingSortedUpgrades
{
    return [NSSet setWithObjects: @"upgrades", @"ship", nil];
}

+(NSSet*)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects: @"upgrades", @"ship", nil];
}

+(NSSet*)keyPathsForValuesAffectingStyledDescription
{
    return [NSSet setWithObjects: @"ship", nil];
}

-(NSString*)title
{
    return self.ship.title;
}

-(NSString*)plainDescription
{
    return [self.ship plainDescription];
}

-(NSAttributedString*)styledDescription
{
    return [self.ship styledDescription];
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

-(int)baseCost
{
    return [self.ship.cost intValue];
}

-(int)cost
{
    int cost = [self.ship.cost intValue];

    for (DockEquippedUpgrade* upgrade in self.upgrades) {
        cost += [upgrade cost];
    }

    return cost;
}

-(DockEquippedUpgrade*)equippedCaptain
{
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

-(DockEquippedShip*)duplicate
{
    DockEquippedShip* newShip = [DockEquippedShip equippedShipWithShip: self.ship];
    for (DockEquippedUpgrade* equippedUpgrade in self.sortedUpgrades) {
        DockUpgrade* upgrade = [equippedUpgrade upgrade];
        if (![upgrade isPlaceholder]) {
            [newShip addUpgrade: equippedUpgrade.upgrade maybeReplace: nil establishPlaceholders: NO];
        }
    }
    [self establishPlaceholders];
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

-(void)establishPlaceholders
{
    DockCaptain* captain = [self captain];

    if (captain == nil) {
        NSString* faction = self.ship.faction;

        if ([faction isEqualToString: @"Independent"] || [faction isEqualToString: @"Bajoran"]) {
            faction = @"Federation";
        }

        DockUpgrade* zcc = [DockCaptain zeroCostCaptain: faction context: self.managedObjectContext];
        [self addUpgrade: zcc maybeReplace: nil establishPlaceholders: NO];
    }

    int count = [self talentCount];
    [self establishPlaceholdersForType: @"Talent" limit: count];
    count = [[self.ship crew] intValue];
    [self establishPlaceholdersForType: @"Crew" limit: count];
    count = [[self.ship weapon] intValue];
    [self establishPlaceholdersForType: @"Weapon" limit: count];
    count = [[self.ship tech] intValue];
    [self establishPlaceholdersForType: @"Tech" limit: count];
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

    if (onesToRemove.count > 0) {
        [self removeUpgrades: onesToRemove];
        [[self squad] squadCompositionChanged];
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

    int limit = [upgrade limitForShip: self];
    return limit > 0;
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

    [self addUpgrades: [NSSet setWithObject: equippedUpgrade]];

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

-(DockEquippedUpgrade*)mostExpensiveUpgradeOfFaction:(NSString*)faction
{
    DockEquippedUpgrade* mostExpensive = nil;
    NSMutableArray* allUpgrades = [[NSMutableArray alloc] init];

    for (DockEquippedUpgrade* eu in self.sortedUpgrades) {
        if (![eu.upgrade isCaptain]) {
            if ([faction isEqualToString: eu.upgrade.faction]) {
                [allUpgrades addObject: eu];
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

                return NSOrderedAscending;
            };
            [allUpgrades sortedArrayUsingComparator: cmp];
        }

        mostExpensive = allUpgrades[0];
    }

    return mostExpensive;
}

-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade
{
    return [self addUpgrade: upgrade maybeReplace: nil];
}

-(void)removeUpgrade:(DockEquippedUpgrade*)upgrade establishPlaceholders:(BOOL)doEstablish
{
    if (upgrade != nil) {
        [self removeUpgrades: [NSSet setWithObject: upgrade]];

        if ([upgrade.upgrade isCaptain]) {
            [self removeAllTalents];
        }

        if (doEstablish) {
            [self establishPlaceholders];
        }

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

-(void)removeCaptain
{
    [self removeUpgrade: [self equippedCaptain]];
}

-(int)talentCount
{
    DockCaptain* captain = [self captain];
    return [captain talentCount];
}

-(int)upgradeCount
{
    int count = 0;
    for (DockEquippedUpgrade* eu in [self sortedUpgrades]) {
        DockUpgrade* upgrade = eu.upgrade;
        if (![upgrade isPlaceholder] && ![upgrade isCaptain]) {
            count += 1;
        }
    }
    return count;
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
}

-(NSDictionary*)explainCantAddUpgrade:(DockUpgrade*)upgrade
{
    NSString* msg = [NSString stringWithFormat: @"Can't add %@ to %@", [upgrade plainDescription], [self plainDescription]];
    NSString* info = @"";
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
        }
    }

    return @{@"info": info, @"message": msg};
}

@end
