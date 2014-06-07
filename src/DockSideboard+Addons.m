#import "DockSideboard+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockResource+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockSideboard (Addons)

+(DockSideboard*)sideboard:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Sideboard"
                                              inManagedObjectContext: context];
    DockSideboard* sideboard = [[DockSideboard alloc] initWithEntity: entity
                                      insertIntoManagedObjectContext: context];
    [sideboard establishPlaceholders];
    return sideboard;
}

-(NSAttributedString*)styledDescription
{
    DockResource* r = [DockResource sideboardResource: self.managedObjectContext];
    return [[NSAttributedString alloc] initWithString: r.title attributes: nil];
}

-(NSString*)shipFaction
{
    return @"Federation";
}

-(int)cost
{
    DockResource* r = [DockResource sideboardResource: self.managedObjectContext];
    return [r.cost intValue];
}

-(int)talentCount
{
    return 1;
}

-(int)techCount
{
    return 1;
}

-(int)weaponCount
{
    return 1;
}

-(int)crewCount
{
    return 1;
}

-(int)captainCount
{
    return 1;
}

-(int)borgCount
{
    return 0;
}

-(BOOL)upgradeWouldExceedCostLimit:(DockUpgrade*)upgrade
{
    int currentCost = [self baseCost];
    if (currentCost + [[upgrade cost] intValue] > 20) {
        return YES;
    }
    return NO;
}

-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade
{
    if ([upgrade isBorg]) {
        return NO;
    }

    return ![self upgradeWouldExceedCostLimit: upgrade];
}

-(int)baseCost
{
    int cost = 0;

    for (DockEquippedUpgrade* upgrade in self.sortedUpgrades) {
        cost += [upgrade.upgrade costForShip: self];
    }
    return cost;
}

-(NSDictionary*)explainCantAddUpgrade:(DockUpgrade*)upgrade
{
    if ([self upgradeWouldExceedCostLimit: upgrade]) {
        NSString* msg = [NSString stringWithFormat: @"Can't add %@ to %@", [upgrade plainDescription], [self plainDescription]];
        NSString* info = [NSString stringWithFormat: @"Adding an item of cost %@ would exceed limit of 20.", [upgrade cost]];
        return @{
                 @"info": info, @"message": msg
                 };
    }
    return [super explainCantAddUpgrade: upgrade];
}

-(NSString*)factionCode
{
    return @"";
}

@end
