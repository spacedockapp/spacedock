#import "DockEquippedShip+Addons.h"

#import "DockEquippedUpgrade.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockShip.h"

@implementation DockEquippedShip (Addons)

-(NSString*)title
{
    return self.ship.title;
}

-(NSString*)description
{
    return [NSString stringWithFormat: @"%@ (%@)", self.ship.title, self.ship.shipClass];
}

-(void)addUpgrade:(DockUpgrade*)upgrade
{
    [self willChangeValueForKey: @"sortedUpgrades"];
    NSManagedObjectContext* context = [self managedObjectContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"EquippedUpgrade" inManagedObjectContext: context];
    DockEquippedUpgrade* equippedUpgrade = [[DockEquippedUpgrade alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
    equippedUpgrade.upgrade = upgrade;
    [self addUpgrades: [NSSet setWithObject: equippedUpgrade]];
    [self didChangeValueForKey: @"sortedUpgrades"];
}

-(NSArray*)sortedUpgrades
{
    NSArray* items = [self.upgrades allObjects];
    return [items sortedArrayUsingComparator: ^(DockEquippedUpgrade* a, DockEquippedUpgrade* b) {
        return [a compareTo: b];
    }];
}

@end
