#import "DockEquippedShip+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedUpgrade.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockShip.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockEquippedShip (Addons)

+ (NSSet *)keyPathsForValuesAffectingSortedUpgrades
{
    return [NSSet setWithObjects:@"upgrades", nil];
}

+ (NSSet *)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects:@"upgrades", nil];
}

-(NSString*)title
{
    return self.ship.title;
}

-(NSString*)description
{
    return [self.ship description];
}

-(NSAttributedString*)styledDescription
{
    NSString* s = [self description];
    return [[NSAttributedString alloc] initWithString: s];
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
                                              inManagedObjectContext:context];
    DockEquippedShip* es = [[DockEquippedShip alloc] initWithEntity: entity
                                     insertIntoManagedObjectContext:context];
    es.ship = ship;
    [es establishPlaceholders];
    return es;
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

-(void)establishPlaceholdersForType:(NSString*)upType limit:(int)limit
{
    NSManagedObjectContext* context = self.managedObjectContext;
    int current = [self equipped: upType];
    for (int i = current; i < limit; ++i) {
        DockUpgrade* upgrade = [DockUpgrade placeholder: upType inContext:context];
        [self addUpgrade: upgrade];
    }
}

-(void)establishPlaceholders
{
    DockCaptain* captain = [self captain];
    if (captain == nil) {
        DockUpgrade* zcc = [DockCaptain zeroCostCaptain: self.ship.faction context: self.managedObjectContext];
        [self addUpgrade: zcc];
    }
    int count = [self talentCount];
    [self establishPlaceholdersForType: @"Talent" limit:count];
    count = [[self.ship crew] intValue];
    [self establishPlaceholdersForType: @"Crew" limit:count];
    count = [[self.ship weapon] intValue];
    [self establishPlaceholdersForType: @"Weapon" limit:count];
    count = [[self.ship tech] intValue];
    [self establishPlaceholdersForType: @"Tech" limit:count];
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
    int limit = [upgrade limitForShip: self];
    return limit > 0;
}

-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade maybeReplace:(DockEquippedUpgrade*)maybeReplace;
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
            NSLog(@"removing placeholder %@", ph);
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
        [self removeUpgrade: maybeReplace establishPlaceholders:NO];
    }
    [self addUpgrades: [NSSet setWithObject: equippedUpgrade]];
    if (![upgrade isPlaceholder]) {
        [self establishPlaceholders];
    }
    [[self squad] squadCompositionChanged];
    return equippedUpgrade;
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

-(NSArray*)sortedUpgrades
{
    NSArray* items = [self.upgrades allObjects];
    return [items sortedArrayUsingComparator: ^(DockEquippedUpgrade* a, DockEquippedUpgrade* b) {
        return [a compareTo: b];
    }];
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

-(NSString*)ability
{
    return self.ship.ability;
}

@end
