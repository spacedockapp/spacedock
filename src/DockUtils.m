#import "DockUtils.h"

#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade.h"

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
    NSNumber* additionalPoints = targetSquad.additionalPoints;
    if (additionalPoints && [additionalPoints intValue] > 0) {
        return [NSString stringWithFormat: @"%@", additionalPoints];
    }
    return @"";
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

