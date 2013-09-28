#import "DockEquippedShip+Addons.h"

#import "DockEquippedUpgrade.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockShip.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockEquippedShip (Addons)

-(NSString*)title
{
    return self.ship.title;
}

-(NSString*)description
{
    return [NSString stringWithFormat: @"%@ (%@)", self.ship.title, self.ship.shipClass];
}

-(int)cost
{
    int cost = [self.ship.cost intValue];
    for (DockEquippedUpgrade* upgrade in self.upgrades) {
        cost += [upgrade cost];
    }
    return cost;
}

-(DockCaptain*)captain
{
    for (DockEquippedUpgrade* eu in self.upgrades) {
        DockUpgrade* upgrade = eu.upgrade;
        if ([upgrade.upType isEqualToString: @"Captain"]) {
            return (DockCaptain*)upgrade;
        }
    }
    return nil;
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
    [self establishPlaceholdersForType: @"Captain" limit:1];
    int count = [[self.ship crew] intValue];
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
    [self willChangeValueForKey: @"sortedUpgrades"];
    [self willChangeValueForKey: @"cost"];
    [self removeUpgrades: onesToRemove];
    [self didChangeValueForKey: @"cost"];
    [self didChangeValueForKey: @"sortedUpgrades"];
    [[self squad] squadCompositionChanged];
    }
}

-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade
{
    int limit = [upgrade limitForShip: self];
    return limit > 0;
}

-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade
{
    [self willChangeValueForKey: @"sortedUpgrades"];
    [self willChangeValueForKey: @"cost"];
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
    [self addUpgrades: [NSSet setWithObject: equippedUpgrade]];
    [self didChangeValueForKey: @"sortedUpgrades"];
    [self didChangeValueForKey: @"cost"];
    [[self squad] squadCompositionChanged];
    return equippedUpgrade;
}

-(void)removeUpgrade:(DockEquippedUpgrade*)upgrade establishPlaceholders:(BOOL)doEstablish
{
    [self willChangeValueForKey: @"sortedUpgrades"];
    [self willChangeValueForKey: @"cost"];
    [self removeUpgrades: [NSSet setWithObject: upgrade]];
    if ([upgrade.upgrade isCaptain]) {
        [self removeAllTalents];
    }
    if (doEstablish) {
        [self establishPlaceholders];
    }
    [self didChangeValueForKey: @"cost"];
    [self didChangeValueForKey: @"sortedUpgrades"];
    [[self squad] squadCompositionChanged];
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

@end
