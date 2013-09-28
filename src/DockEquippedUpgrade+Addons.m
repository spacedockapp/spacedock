#import "DockEquippedUpgrade+Addons.h"

#import "DockCaptain.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade.h"
#import "DockShip+Addons.h"
#import "DockUpgrade+Addons.h"

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
    DockCaptain* captain = self.equippedShip.captain;
    NSString* captainSpecial = captain.special;
    NSString* upgradeSpecial = upgrade.special;
    if ([upgrade isTalent]) {
        if ([captainSpecial isEqualToString: @"BaselineTalentCostToThree"]) {
            cost = 3;
        }
    } else if ([upgrade isCrew]) {
        if ([captainSpecial isEqualToString: @"CrewUpgradesCostOneLess"]) {
            cost -= 1;
        }
        
        if ([upgradeSpecial isEqualToString: @"costincreasedifnotromulansciencevessel"]) {
            if ([ship.shipClass isEqualToString: @"Romulan Science Vessel"]) {
                cost += 5;
            }
        }
    } else if ([upgrade isWeapon]) {
        if ([captainSpecial isEqualToString: @"WeaponUpgradesCostOneLess"]) {
           cost -= 1;
        }
    }
    
    if ([upgradeSpecial isEqualToString: @"costincreasedifnotbreen"]) {
        if (![ship isBreen]) {
            cost += 5;
        }
    }
    
    if (![shipFaction isEqualToString: upgradeFaction]) {
        if ([captainSpecial isEqualToString: @"UpgradesIgnoreFactionPenalty"]) {
        } else if ([captainSpecial isEqualToString: @"CaptainAndTalentsIgnoreFactionPenalty"] &&
            ([upgrade isTalent] || [upgrade isCaptain])) {
        } else {
            cost += 1;
        }
    }
    return cost;
}

-(NSComparisonResult)compareTo:(DockEquippedUpgrade*)other
{

    return [[self upgrade] compareTo: [other upgrade]];
}


@end
