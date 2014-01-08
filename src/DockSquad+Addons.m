#import "DockSquad+Addons.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockErrors.h"
#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
#import "DockSideboard+Addons.h"
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

+(NSSet*)allNames:(NSManagedObjectContext*)context
{
    NSArray* allSquads = [DockSquad allSquads: context];
    NSMutableSet* allNames = [[NSMutableSet alloc] initWithCapacity: allSquads.count];

    for (DockSquad* s in allSquads) {
        [allNames addObject: s.name];
    }
    return [NSSet setWithSet: allNames];
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
            } else if ([label isEqualToString: @"Sideboard"]) {
                DockResource* resource = [DockResource resourceForId: externalId context: context];
                squad.resource = resource;
                currentShip = [squad getSideboard];
            } else if (currentShip != nil) {
                if (externalId.length > 0) {
                    if ([label isEqualToString: @"Resources"]) {
                        DockResource* resource = [DockResource resourceForId: externalId context: context];

                        if (![resource isSideboard]) {
                            squad.resource = resource;
                        }
                    } else {
                        DockUpgrade* upgrade = [DockUpgrade upgradeForId: externalId context: context];
                        [currentShip addUpgrade: upgrade];
                    }
                }
            }
        }
    }
    #if !TARGET_OS_IPHONE
    [context commitEditing];
    #endif
    return squad;
}

+(NSSet*)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects: @"equippedShips", @"resource", @"additionalPoints", nil];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (![self isFault]) {
        [self squadCompositionChanged];
    }
}

-(void)watchForCostChange
{
    for (DockEquippedShip* es in self.equippedShips) {
        [es addObserver: self forKeyPath: @"cost" options: 0 context: 0];
    }
}

-(void)stopWatchingForCostChange
{
    for (DockEquippedShip* es in self.equippedShips) {
        [es removeObserver: self forKeyPath: @"cost"];
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

- (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags
{
    [super awakeFromSnapshotEvents: flags];
    [self watchForCostChange];
}

- (void)willTurnIntoFault
{
    [self stopWatchingForCostChange];
}

-(void)addEquippedShip:(DockEquippedShip*)ship
{
    id compareIsSideboard = ^(DockEquippedShip* a, DockEquippedShip* b) {
        if (a.isResourceSideboard == b.isResourceSideboard) {
            return NSOrderedSame;
        }

        if (a.isResourceSideboard) {
            return NSOrderedDescending;
        }

        return NSOrderedAscending;
    };

    [self willChangeValueForKey: @"cost"];
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet: self.equippedShips];
    [tempSet addObject: ship];
    [tempSet sortUsingComparator: compareIsSideboard];
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
        if (![ship isResourceSideboard]) {
            cost += [ship cost];
        }
    }

    if (self.resource != nil) {
        cost += [self.resource.cost intValue];
    }
    
    if (self.additionalPoints != nil) {
        cost += [self.additionalPoints intValue];
    }

    return cost;
}

-(void)squadCompositionChanged
{
    [self willChangeValueForKey: @"cost"];
    [self didChangeValueForKey: @"cost"];
}

-(NSString*)shipsDescription
{
    NSMutableArray* shipTitles = [NSMutableArray arrayWithCapacity: self.equippedShips.count];

    for (DockEquippedShip* ship in self.equippedShips) {
        [shipTitles addObject: ship.plainDescription];
    }
    return [shipTitles componentsJoinedByString: @", "];
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

-(NSString*)asPlainTextFormat
{
    NSMutableString* textFormat = [[NSMutableString alloc] init];

    for (DockEquippedShip* ship in self.equippedShips) {
        NSString* s = [NSString stringWithFormat: @"%@ (%d)\n", ship.plainDescription, [ship baseCost]];
        [textFormat appendString: s];

        for (DockEquippedUpgrade* upgrade in ship.sortedUpgrades) {
            if (![upgrade isPlaceholder]) {

                s = [NSString stringWithFormat: @"%@ (%d)\n", upgrade.title, [upgrade cost]];
                [textFormat appendString: s];
            }
        }

        if (![ship isResourceSideboard]) {
            s = [NSString stringWithFormat: @"Total (%d)\n", ship.cost];
            [textFormat appendString: s];
        }

        [textFormat appendString: @"\n"];
    }

    DockResource* resource = self.resource;

    if (resource != nil) {
        NSString* resourceString = [NSString stringWithFormat: @"%@ (%@)\n", resource.title, [resource cost]];
        [textFormat appendString: resourceString];
        [textFormat appendString: @"\n"];
    }

    [textFormat appendString: [NSString stringWithFormat: @"Fleet total: %d\n", self.cost]];
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
        if ([ship isResourceSideboard]) {
            [dataFormat appendString: toDataFormat(@"Sideboard", ship.squad.resource)];
        } else {
            [dataFormat appendString: toDataFormat(@"Ships", ship.ship)];
        }

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

static NSString* namePrefix(NSString* originalName)
{
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern: @" copy *\\d*"
                                                                                options: NSRegularExpressionCaseInsensitive
                                                                                  error: nil];
    NSArray* matches = [expression matchesInString: originalName options: 0 range: NSMakeRange(0, originalName.length)];

    if (matches.count > 0) {
        NSTextCheckingResult* r = [matches lastObject];
        return [originalName substringToIndex: r.range.location];
    }

    return originalName;
}

-(DockSquad*)duplicate
{
    NSManagedObjectContext* context = [self managedObjectContext];
    NSEntityDescription* squadEntity = [NSEntityDescription entityForName: @"Squad" inManagedObjectContext: context];
    DockSquad* squad = [[DockSquad alloc] initWithEntity: squadEntity insertIntoManagedObjectContext: context];
    NSString* originalNamePrefix = namePrefix(self.name);
    NSString* newName = [originalNamePrefix stringByAppendingString: @" copy"];
    NSSet* allNames = [DockSquad allNames: context];
    int index = 2;

    while ([allNames containsObject: newName]) {
        newName = [NSString stringWithFormat: @"%@ copy %d", originalNamePrefix, index];
        index += 1;
    }
    squad.name = newName;

    for (DockEquippedShip* ship in self.equippedShips) {
        DockEquippedShip* dup = [ship duplicate];
        [squad addEquippedShip: dup];
    }
    squad.resource = self.resource;
    squad.notes = self.notes;
    squad.additionalPoints = self.additionalPoints;
    return squad;
}

-(DockEquippedUpgrade*)addCaptain:(DockCaptain*)captain toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    if (![self canAddCaptain: captain toShip: targetShip error: error]) {
        return nil;
    }

    [targetShip removeCaptain];
    return [targetShip addUpgrade: captain];
}

-(BOOL)canAddCaptain:(DockCaptain*)captain toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    DockCaptain* existingCaptain = [targetShip captain];

    if (captain == existingCaptain) {
        return YES;
    }

    if ([captain isUnique]) {
        DockEquippedUpgrade* existing = [self containsUpgradeWithName: captain.title];

        if (existing) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"This Captain is unique and one with the same name already exists in the squadron.";
                NSDictionary* d = @{
                    NSLocalizedDescriptionKey: msg,
                    NSLocalizedFailureReasonErrorKey: info,
                    DockExistingUpgradeKey: existing
                };
                *error = [NSError errorWithDomain: DockErrorDomain code: kUniqueConflict userInfo: d];
            }

            return NO;
        }
    }

    return YES;
}

-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    if ([upgrade isUnique]) {
        DockEquippedUpgrade* existing = [self containsUpgradeWithName: upgrade.title];

        if (existing) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", upgrade.title];
                NSString* info = [NSString stringWithFormat: @"This %@ is unique and one with the same name already exists in the squadron.", upgrade.upType];
                NSDictionary* d = @{
                    NSLocalizedDescriptionKey: msg,
                    NSLocalizedFailureReasonErrorKey: info,
                    DockExistingUpgradeKey: existing
                };
                *error = [NSError errorWithDomain: DockErrorDomain code: kUniqueConflict userInfo: d];
            }

            return NO;
        }
    }

    if (![targetShip canAddUpgrade: upgrade]) {
        if (error) {
            NSDictionary* reasons = [targetShip explainCantAddUpgrade: upgrade];
            NSDictionary* d = @{
                NSLocalizedDescriptionKey: reasons[@"message"],
                NSLocalizedFailureReasonErrorKey: reasons[@"info"]
            };
            *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
        }

        return NO;
    }

    return YES;
}

-(DockEquippedShip*)getSideboard
{
    DockEquippedShip* sideboard = nil;

    for (DockEquippedShip* target in self.equippedShips) {
        if (target.isResourceSideboard) {
            sideboard = target;
            break;
        }
    }
    return sideboard;
}

-(DockEquippedShip*)addSideboard
{
    DockEquippedShip* sideboard = [self getSideboard];
    if (sideboard == nil) {
        sideboard = [DockSideboard sideboard: [self managedObjectContext]];
        [self addEquippedShip: sideboard];
    }
    return sideboard;
}

-(DockEquippedShip*)removeSideboard
{
    DockEquippedShip* sideboard = [self getSideboard];

    if (sideboard) {
        [self removeEquippedShip: sideboard];
    }

    return sideboard;
}

-(void)removeFlagship
{
    for (DockEquippedShip* equippedShip in self.equippedShips) {
        [equippedShip removeFlagship];
    }
}

-(void)setResource:(DockResource*)resource
{
    DockResource* oldResource = [self primitiveValueForKey: @"resource"];
    
    if (oldResource != resource) {

        if ([oldResource isSideboard]) {
            [self removeSideboard];
        } else if ([oldResource isFlagship]) {
            [self removeFlagship];
        }

        [self willChangeValueForKey: @"resource"];
        [self setPrimitiveValue: resource forKey: @"resource"];
        [self didChangeValueForKey: @"resource"];

        if ([resource isSideboard]) {
            [self addSideboard];
        }
        
    }
}

-(DockFlagship*)flagship
{
    for (DockEquippedShip* equippedShip in self.equippedShips) {
        DockFlagship* flagShip = equippedShip.flagship;
        if (flagShip != nil) {
            return flagShip;
        }
    }
    return nil;
}

@end
