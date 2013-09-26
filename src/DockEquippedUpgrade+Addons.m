#import "DockEquippedUpgrade+Addons.h"

#import "DockEquippedShip.h"
#import "DockEquippedUpgrade.h"
#import "DockShip.h"
#import "DockUpgrade+Addons.h"
#import "DockUpgrade.h"

@implementation DockEquippedUpgrade (Addons)

-(NSString*)title
{
    return self.upgrade.title;
}

-(NSString*)description
{
    return self.upgrade.description;
}

-(NSArray*)sortedUpgrades
{
    return nil;
}

-(int)cost
{
    DockShip* ship = self.equippedShip.ship;
    DockUpgrade* upgrade = self.upgrade;
    int cost = [upgrade.cost intValue];
    NSString* shipFaction = ship.faction;
    NSString* upgradeFaction = upgrade.faction;
    if (![shipFaction isEqualToString: upgradeFaction]) {
        cost += 1;
    }
    return cost;
}

-(NSComparisonResult)compareTo:(DockEquippedUpgrade*)other
{

    return [[self upgrade] compareTo: [other upgrade]];
}


@end
