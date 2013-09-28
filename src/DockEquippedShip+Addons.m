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
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"EquippedShip" inManagedObjectContext:context];
    DockEquippedShip* es = [[DockEquippedShip alloc] initWithEntity: entity insertIntoManagedObjectContext:context];
    int count = [[ship crew] intValue];
    for (int i = 0; i < count; ++i) {
        DockUpgrade* upgrade = [DockUpgrade placeholder: @"Crew" inContext:context];
        [es addUpgrade: upgrade];
    }
    count = [[ship weapon] intValue];
    for (int i = 0; i < count; ++i) {
        DockUpgrade* upgrade = [DockUpgrade placeholder: @"Weapon" inContext:context];
        [es addUpgrade: upgrade];
    }
    count = [[ship tech] intValue];
    for (int i = 0; i < count; ++i) {
        DockUpgrade* upgrade = [DockUpgrade placeholder: @"Tech" inContext:context];
        [es addUpgrade: upgrade];
    }
    return es;
}

-(DockEquippedUpgrade*)findPlaceholder:(NSString*)upType
{
    for (DockEquippedUpgrade* eu in self.upgrades) {
        if ([eu isPlaceholder]) {
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
            [self removeUpgrade: ph];
        }
    }
    [self addUpgrades: [NSSet setWithObject: equippedUpgrade]];
    [self didChangeValueForKey: @"sortedUpgrades"];
    [self didChangeValueForKey: @"cost"];
    [[self squad] squadCompositionChanged];
    return equippedUpgrade;
}

-(void)removeUpgrade:(DockEquippedUpgrade*)upgrade
{
    [self willChangeValueForKey: @"sortedUpgrades"];
    [self willChangeValueForKey: @"cost"];
    [self removeUpgrades: [NSSet setWithObject: upgrade]];
    if ([upgrade.upgrade isCaptain]) {
        [self removeAllTalents];
    }
    [self didChangeValueForKey: @"cost"];
    [self didChangeValueForKey: @"sortedUpgrades"];
    [[self squad] squadCompositionChanged];
}

-(NSArray*)sortedUpgrades
{
    NSArray* items = [self.upgrades allObjects];
    return [items sortedArrayUsingComparator: ^(DockEquippedUpgrade* a, DockEquippedUpgrade* b) {
        return [a compareTo: b];
    }];
}

@end
