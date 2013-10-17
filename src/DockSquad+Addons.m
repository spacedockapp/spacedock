#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockSquad (Addons)

+(NSArray*)allSquads:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Squad" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    return [context executeFetchRequest: request error: &err];
}

+(DockSquad*)import:(NSString*)name data:(NSString*)datFormatString context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Squad"
                                              inManagedObjectContext: context];
    DockSquad* squad = [[DockSquad alloc] initWithEntity: entity
                          insertIntoManagedObjectContext: context];
    squad.name = name;

    DockEquippedShip* currentShip = nil;
    NSArray* lines = [datFormatString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];

    for (NSString* line in lines) {
        NSArray* parts = [line componentsSeparatedByString: @"|"];

        if (parts.count >= 3) {
            NSString* label = parts[0];
            NSString* externalId = parts[2];

            if ([label isEqualToString: @"Ships"]) {
                DockShip* ship = [DockShip shipForId: externalId context: context];

                if (ship != nil) {
                    currentShip = [DockEquippedShip equippedShipWithShip: ship];
                    [squad addEquippedShip: currentShip];
                }
            } else if (currentShip != nil) {
                if (externalId.length > 0) {
                    if ([label isEqualToString: @"Resources"]) {
                        DockResource* resource = [DockResource resourceForId: externalId context: context];
                        squad.resource = resource;
                    } else {
                        DockUpgrade* upgrade = [DockUpgrade upgradeForId: externalId context: context];
                        [currentShip addUpgrade: upgrade];
                    }
                }
            }
        }
    }
    [context commitEditing];
    return squad;
}

+(NSSet*)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects: @"equippedShips", @"resource", nil];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    [self squadCompositionChanged];
}

-(void)watchForCostChange
{
    for (DockEquippedShip* es in self.equippedShips) {
        [es addObserver: self forKeyPath: @"cost" options: 0 context: 0];
    }
}

-(void)awakeFromInsert
{
    [super awakeFromInsert];
    [self watchForCostChange];
}

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    [self watchForCostChange];
}

-(void)addEquippedShip:(DockEquippedShip*)ship
{
    [self willChangeValueForKey: @"cost"];
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet: self.equippedShips];
    [tempSet addObject: ship];
    self.equippedShips = tempSet;
    [self didChangeValueForKey: @"cost"];
    [ship addObserver: self forKeyPath: @"cost" options: 0 context: 0];
}

-(void)removeEquippedShip:(DockEquippedShip*)ship
{
    [self willChangeValueForKey: @"cost"];
    NSMutableOrderedSet* tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet: [self mutableOrderedSetValueForKey: @"equippedShips"]];
    NSUInteger idx = [tmpOrderedSet indexOfObject: ship];

    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex: idx];
        [self willChange: NSKeyValueChangeRemoval valuesAtIndexes: indexes forKey: @"equippedShips"];
        [tmpOrderedSet removeObject: ship];
        [self setPrimitiveValue: tmpOrderedSet forKey: @"equippedShips"];
        [self didChange: NSKeyValueChangeRemoval valuesAtIndexes: indexes forKey: @"equippedShips"];
    }

    [ship removeObserver:  self forKeyPath: @"cost"];
    [self didChangeValueForKey: @"cost"];
}

-(int)cost
{
    int cost = 0;

    for (DockEquippedShip* ship in self.equippedShips) {
        cost += [ship cost];
    }

    if (self.resource != nil) {
        cost += [self.resource.cost intValue];
    }

    return cost;
}

-(void)squadCompositionChanged
{
    [self willChangeValueForKey: @"cost"];
    [self didChangeValueForKey: @"cost"];
}

-(NSString*)asTextFormat
{
    NSMutableString* textFormat = [[NSMutableString alloc] init];
    NSString* header = [NSString stringWithFormat: @"Type    %@ %@  %@\n", [@"Card Title" stringByPaddingToLength : 40 withString : @" " startingAtIndex : 0], @"Faction", @"SP"];
    [textFormat appendString: header];
    int i = 1;

    for (DockEquippedShip* ship in self.equippedShips) {
        NSString* s = [NSString stringWithFormat: @"Ship %d  %@ %1@  %5d\n", i, [ship.title stringByPaddingToLength: 43 withString: @" " startingAtIndex: 0], [ship.ship.faction substringToIndex: 1], [ship.ship.cost intValue]];
        [textFormat appendString: s];

        for (DockEquippedUpgrade* upgrade in ship.sortedUpgrades) {
            if (![upgrade isPlaceholder]) {

                if ([upgrade.upgrade isCaptain]) {
                    s = [NSString stringWithFormat: @" Cap    %@ %1@  %5d\n", [upgrade.title stringByPaddingToLength: 43 withString: @" " startingAtIndex: 0], [upgrade.faction substringToIndex: 1], upgrade.cost];
                } else {
                    s = [NSString stringWithFormat: @"  %@     %@ %1@  %5d\n", [upgrade typeCode], [upgrade.title stringByPaddingToLength: 43 withString: @" " startingAtIndex: 0], [upgrade.faction substringToIndex: 1], upgrade.cost];
                }

                [textFormat appendString: s];
            }
        }
        s = [NSString stringWithFormat: @"                                                 Total %5d\n", ship.cost];
        [textFormat appendString: s];
        [textFormat appendString: @"\n"];
        i += 1;
    }
    DockResource* resource = self.resource;

    if (resource != nil) {
        NSString* resourceString = [NSString stringWithFormat: @"Resource: %@     %5d\n\n",
                                    [resource.title stringByPaddingToLength: 40 withString: @" " startingAtIndex: 0],
                                    [resource.cost intValue]];
        [textFormat appendString: resourceString];
    }

    [textFormat appendString: [NSString stringWithFormat: @"Total Build: %d\n", self.cost]];
    return [NSString stringWithString: textFormat];
}

static NSString* toDataFormat(NSString* label, id element)
{
    return [NSString stringWithFormat: @"%@|%@|%@\n", label, [element title], [element externalId]];
}

-(NSString*)asDataFormat
{
    NSMutableString* dataFormat = [[NSMutableString alloc] init];
    int i = 0;

    for (DockEquippedShip* ship in self.equippedShips) {
        [dataFormat appendString: toDataFormat(@"Ships", ship.ship)];

        for (DockEquippedUpgrade* upgrade in ship.sortedUpgrades) {
            if ([upgrade isPlaceholder]) {
                [dataFormat appendString: @"Upgrades||\n"];
            } else if ([upgrade.upgrade isCaptain]) {
                [dataFormat appendString: toDataFormat(@"Captains", upgrade.upgrade)];
            } else {
                [dataFormat appendString: toDataFormat(@"Upgrades", upgrade.upgrade)];
            }
        }
        i += 1;
    }

    DockResource* resource = self.resource;

    if (resource != nil) {
        [dataFormat appendString: toDataFormat(@"Resources", resource)];
    }

    return [NSString stringWithString: dataFormat];
}

-(DockEquippedShip*)containsShip:(DockShip*)theShip
{
    for (DockEquippedShip* ship in self.equippedShips) {
        if (ship.ship == theShip) {
            return ship;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)containsUpgrade:(DockUpgrade*)theUpgrade
{
    for (DockEquippedShip* ship in self.equippedShips) {
        DockEquippedUpgrade* existing = [ship containsUpgrade: theUpgrade];

        if (existing) {
            return existing;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)containsUpgradeWithName:(NSString*)theName
{
    for (DockEquippedShip* ship in self.equippedShips) {
        DockEquippedUpgrade* existing = [ship containsUpgradeWithName: theName];

        if (existing) {
            return existing;
        }
    }
    return nil;
}

@end
