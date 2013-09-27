#import "DockEquippedShip+Addons.h"

#import "DockEquippedUpgrade.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockShip.h"
#import "DockSquad+Addons.h"

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

-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade
{
    [self willChangeValueForKey: @"sortedUpgrades"];
    [self willChangeValueForKey: @"cost"];
    NSManagedObjectContext* context = [self managedObjectContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"EquippedUpgrade" inManagedObjectContext: context];
    DockEquippedUpgrade* equippedUpgrade = [[DockEquippedUpgrade alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
    equippedUpgrade.upgrade = upgrade;
    [self addUpgrades: [NSSet setWithObject: equippedUpgrade]];
    [self didChangeValueForKey: @"sortedUpgrades"];
    [self didChangeValueForKey: @"cost"];
    [[self squad] squadCompositionChanged];
    return equippedUpgrade;
}

-(void)removeUpgrade:(DockUpgrade*)upgrade
{
    [self willChangeValueForKey: @"sortedUpgrades"];
    [self willChangeValueForKey: @"cost"];
    [self removeUpgrades: [NSSet setWithObject: upgrade]];
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
