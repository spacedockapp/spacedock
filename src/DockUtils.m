#import "DockUtils.h"

#import "DockConstants.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

NSString* intToString(int v)
{
    return [NSString stringWithFormat: @"%d", v];
}

NSSet* allAttributes(NSManagedObjectContext* context, NSString* entityName, NSString* attributeName)
{
    NSMutableSet* allSpecials = [NSMutableSet setWithCapacity: 0];
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        for (id item in existingItems) {
            NSString* attributeValue = [item valueForKey: attributeName];

            if ([attributeValue length] > 0) {
                [allSpecials addObject: attributeValue];
            }
        }
    }

    return [NSSet setWithSet: allSpecials];
}


NSString* factionCode(id target)
{
    NSString* faction = [target faction];
    return [faction substringToIndex: 3];
}

NSString* resourceCost(DockSquad* targetSquad)
{
    DockResource* res = targetSquad.resource;
    if (res) {
        if (res.isFlagship || res.isFighterSquadron || res.isSideboard) {
            return @"Inc";
        }
        return [NSString stringWithFormat: @"%@", res.cost];
    }
    return @"";
}

NSString* otherCost(DockSquad* targetSquad)
{
    NSOrderedSet* equippedShips = targetSquad.equippedShips;
    if (equippedShips.count > 4) {
        int otherPageCost = [[targetSquad additionalPoints] intValue];
        for (int secondPageIndex = 4; secondPageIndex < equippedShips.count; ++secondPageIndex) {
            DockEquippedShip* equippedShip = equippedShips[secondPageIndex];
            otherPageCost += equippedShip.cost;
        }
        return [NSString stringWithFormat: @"%d", otherPageCost];
    }
    NSNumber* additionalPoints = targetSquad.additionalPoints;
    if (additionalPoints && [additionalPoints intValue] > 0) {
        return [NSString stringWithFormat: @"%@", additionalPoints];
    }
    return @"";
}

NSString* costString(DockEquippedUpgrade* equippedUpgrade)
{
    int baseCost = [equippedUpgrade.upgrade.cost intValue];
    int costForShip = [equippedUpgrade cost];

    if (baseCost == costForShip) {
        NSString* costString = [NSString stringWithFormat: @"%d", costForShip];
        return costString;
    }

    NSString* costString = [NSString stringWithFormat: @"%d", costForShip];
    NSString* baseCostString = [NSString stringWithFormat: @" (%d)", baseCost];
    return [costString stringByAppendingString: baseCostString];
}

NSArray* actionStrings(id target)
{
    NSMutableArray* actionStringParts = [NSMutableArray arrayWithCapacity: 0];

    if ([[target scan] intValue]) {
        [actionStringParts addObject: @"Scan"];
    }

    if ([[target cloak] intValue]) {
        [actionStringParts addObject: @"Cloak"];
    }

    if ([[target sensorEcho] intValue]) {
        [actionStringParts addObject: @"Echo"];
    }

    if ([[target battleStations] intValue]) {
        [actionStringParts addObject: @"Battle"];
    }

    if ([[target evasiveManeuvers] intValue]) {
        [actionStringParts addObject: @"Evasive"];
    }

    if ([[target targetLock] intValue]) {
        [actionStringParts addObject: @"Lock"];
    }

    if ([[target regenerate] intValue]) {
        [actionStringParts addObject: @"Regen"];
    }

    return [NSArray arrayWithArray: actionStringParts];
}

BOOL targetHasFaction(NSString* faction, id<DockFactioned> target)
{
    return [target.faction isEqualToString: faction] || [target.additionalFaction isEqualToString: faction];
}

BOOL factionsMatch(id<DockFactioned> a, id<DockFactioned> b)
{
    if (targetHasFaction(a.faction, b)) {
        return true;
    }
    
    return targetHasFaction(a.additionalFaction, b);
}

NSString* combinedFactionString(id<DockFactioned> a)
{
    NSString* faction = a.faction;
    NSString* additionalFaction = a.additionalFaction;
    if (additionalFaction.length > 0) {
        return [NSString stringWithFormat: @"%@, %@", faction, additionalFaction];
    }
    return faction;
}

NSURL* applicationFilesDirectory()
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* appSupportURL = [[fileManager URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent: kDockBundleIdentifier];
}
