#import "DockSquad+Addons.h"

#import "DockAdmiral.h"
#import "DockBackupManager.h"
#import "DockCaptain+Addons.h"
#import "DockConstants.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockErrors.h"
#import "DockFlagship+Addons.h"
#import "DockFleetCaptain+Addons.h"
#import "DockOfficer+Addons.h"
#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
#import "DockSideboard+Addons.h"
#import "DockUpgrade+Addons.h"

#import "ISO8601DateFormatter.h"
#import "NSMutableDictionary+Addons.h"

static BOOL sIsImporting = NO;

@implementation DockSquad (Addons)

+(void)startImport
{
    sIsImporting = YES;
}

+(void)doneImport
{
    sIsImporting = NO;
}

+(BOOL)sIsImporting
{
    return sIsImporting;
}

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

+(DockSquad*)squad:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Squad"
                                              inManagedObjectContext: context];
    DockSquad* squad = [[DockSquad alloc] initWithEntity: entity
                          insertIntoManagedObjectContext: context];
    [squad assignNewUUID];
    squad.modified = [NSDate date];
    return squad;
}

+(DockSquad*)import:(NSString*)name data:(NSString*)datFormatString context:(NSManagedObjectContext*)context
{
    DockSquad* squad = [DockSquad squad: context];
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

+(void)import:(NSString*)dataFormatString context:(NSManagedObjectContext*)context
{
    NSError* error;
    NSData* data = [dataFormatString dataUsingEncoding: NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
    if ([json isKindOfClass: [NSArray class]]) {
    } else {
        [DockSquad importOneSquad: json context: context];
    }
}

+(DockSquad*)importOneSquad:(NSDictionary*)squadData replaceUUID:(BOOL)replaceUUID context:(NSManagedObjectContext*)context;
{
    DockSquad* squad = [DockSquad squad: context];
    [squad importIntoSquad: squadData replaceUUID: replaceUUID];
    return squad;
}

+(DockSquad*)importOneSquad:(NSDictionary*)squadData context:(NSManagedObjectContext*)context
{
    return [self importOneSquad: squadData replaceUUID: YES context: context];
}

+(DockSquad*)importOneSquadFromString:(NSString*)squadData context:(NSManagedObjectContext*)context
{
    DockSquad* squad = nil;
    NSError* error;
    NSData* data = [squadData dataUsingEncoding: NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
    if ([json isKindOfClass: [NSArray class]]) {
        json = [json objectAtIndex: 0];
    }
    squad = [DockSquad importOneSquad: json context: context];
    return squad;
}

+ (NSData *)allSquadsAsJSON:(NSManagedObjectContext *)context error:(NSError **)error
{
    NSArray* allSquads = [DockSquad allSquads: context];
    NSMutableArray* squadsForJSONArray = [NSMutableArray arrayWithCapacity: allSquads.count];
    for (DockSquad* squad in [DockSquad allSquads: context]) {
        [squadsForJSONArray addObject: [squad asJSON]];
    }
    
    return [NSJSONSerialization dataWithJSONObject: squadsForJSONArray options: NSJSONWritingPrettyPrinted error: error];
}

+(NSError*)saveSquadsToDisk:(NSString*)targetPath context:(NSManagedObjectContext*)context
{
    NSError *error = nil;
    NSData *squadData = [self allSquadsAsJSON:context error: &error];
    if (squadData != nil) {
        [squadData writeToFile: targetPath atomically: YES];
    }
    return error;
}

-(void)importIntoSquad:(NSDictionary*)squadData replaceUUID:(BOOL)replaceUUID
{
    NSManagedObjectContext* context = self.managedObjectContext;
    self.name = squadData[@"name"];
    self.additionalPoints = squadData[@"additionalPoints"];
    self.notes = squadData[@"notes"];
    
    NSString* uuid = squadData[@"uuid"];
    if (replaceUUID || uuid == nil) {
        [self assignNewUUID];
    } else {
        self.uuid = uuid;
    }
    self.modifiedAsString = squadData[@"modified"];

    [self removeAllEquippedShips];

    NSString* resourceId = squadData[@"resource"];
    if (resourceId != nil) {
        DockResource* resource = [DockResource resourceForId: resourceId context: context];
        self.resource = resource;
    } else {
        self.resource = nil;
    }

    NSArray* ships = squadData[@"ships"];

    DockEquippedShip* currentShip = nil;

    for (NSDictionary* esDict in ships) {
        if ([esDict[@"sideboard"] boolValue]) {
            currentShip = [self getSideboard];
            [currentShip importUpgrades: esDict];
        } else {
            currentShip = [DockEquippedShip import: esDict context: context];
            if (currentShip && !currentShip.isFighterSquadron) {
                [self addEquippedShip: currentShip];
            }
        }
    }
    #if !TARGET_OS_IPHONE
    [context commitEditing];
    #endif
}


-(void)checkAndUpdateFileAtPath:(NSString*)path
{
    NSData* json = [self asJSONData];
    NSData* diskJson = [NSData dataWithContentsOfFile: path];
    if (![json isEqualToData: diskJson]) {
        [json writeToFile: path atomically: NO];
    }
}

+(NSSet*)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects: @"equippedShips", @"resource", @"additionalPoints", nil];
}

+(DockSquad*)squadForUUID:(NSString*)uuid context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Squad" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"uuid == %@", uuid];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

+(void)deleteAllSquads:(NSManagedObjectContext*)context
{
    NSArray* allSquads = [DockSquad allSquads: context];
    for (DockSquad* squad in allSquads) {
        [context deleteObject: squad];
    }
}

+(void)assignUUIDs:(NSManagedObjectContext*)context
{
    for(DockSquad* squad in [DockSquad allSquads: context]) {
        if (squad.uuid == nil) {
            NSUUID* uuid = [NSUUID UUID];
            squad.uuid = [uuid UUIDString];
        }
    }
}

-(void)assignNewUUID
{
    NSUUID* uuid = [NSUUID UUID];
    self.uuid = [uuid UUIDString];
}

-(void)maybeAssignNewUUID
{
    if (self.uuid == nil) {
        [self assignNewUUID];
    }
}

-(void)handleNewInsertedOrReplaced:(NSDictionary*)change
{
    NSArray* newInsertedOrReplaced = [change objectForKey: NSKeyValueChangeNewKey];
    if (newInsertedOrReplaced != (NSArray*)[NSNull null]) {
        for (DockEquippedShip* es in newInsertedOrReplaced) {
            [es addObserver: self forKeyPath: @"cost" options: 0 context: 0];
        }
    }
}

-(void)handleOldRemovedOrReplaced:(NSDictionary*)change
{
    NSArray* oldRemovedOrReplaced = [change objectForKey: NSKeyValueChangeOldKey];
    if (oldRemovedOrReplaced != (NSArray*)[NSNull null]) {
        for (DockEquippedShip* es in oldRemovedOrReplaced) {
            [es removeObserver: self forKeyPath: @"cost"];
        }
    }
}


-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (![self isFault]) {
        if ([keyPath isEqualToString: @"cost"]) {
            [self squadCompositionChanged];
        } else {
            NSUInteger kind = [[change valueForKey: NSKeyValueChangeKindKey] integerValue];
            switch (kind) {
            case NSKeyValueChangeInsertion:
                [self handleNewInsertedOrReplaced: change];
                break;
            case NSKeyValueChangeRemoval:
                [self handleOldRemovedOrReplaced: change];
                break;
            case NSKeyValueChangeSetting:
                [self handleNewInsertedOrReplaced: change];
                [self handleOldRemovedOrReplaced: change];
                break;
            default:
                NSLog(@"unhandled kind in observeValueForKeyPath: %@", change);
                break;
            }
        }
    }
}

-(void)watchForCostChange
{
    for (DockEquippedShip* es in self.equippedShips) {
        [es addObserver: self forKeyPath: @"cost" options: 0 context: 0];
    }
    [self addObserver: self forKeyPath: @"equippedShips" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context: 0];
}

-(void)stopWatchingForCostChange
{
    for (DockEquippedShip* es in self.equippedShips) {
        [es removeObserver: self forKeyPath: @"cost"];
    }
    [self removeObserver: self forKeyPath: @"equippedShips"];
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
        if (a.isResourceSideboard) {
            if (b.isResourceSideboard) {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }
        
        if (a.isFighterSquadron) {
            if (b.isFighterSquadron) {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }
        
        if (a.isFighterSquadron) {
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

    [self didChangeValueForKey: @"cost"];
    if (ship.isFighterSquadron) {
        self.resource = nil;
    }
}

- (void)removeAllEquippedShips
{
    NSInteger existingCount = self.equippedShips.count;
    if (existingCount > 0) {
        NSArray* theShips = [NSArray arrayWithArray: self.equippedShips.array];
        for (DockEquippedShip *es in theShips) {
            [self removeEquippedShip: es];
        }
    }
}

-(int)cost
{
    int cost = 0;

    for (DockEquippedShip* ship in self.equippedShips) {
        cost += [ship cost];
    }

    DockResource* resource = self.resource;
    if (![resource isEquippedIntoSquad: self]) {
        cost += [[self.resource costForSquad:self] intValue];
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

-(void)updateModificationDate
{
    if (![DockSquad sIsImporting]) {
        NSDate *now = [NSDate date];
        NSDate* modified = self.modified;
        if (modified == nil || [now timeIntervalSinceDate:modified] > 1.0) {
            self.modified = now;
            [[DockBackupManager sharedBackupManager] setSquadHasChanged: YES];
        }
    }
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

    DockResource* resource = self.resource;

    for (DockEquippedShip* ship in self.equippedShips) {
        NSString* s = [ship asPlainTextFormat];
        [textFormat appendString: s];
    }

    if (resource != nil && ![resource isEquippedIntoSquad: self]) {
        NSString* resourceString = [resource asPlainTextFormat];
        [textFormat appendString: resourceString];
        [textFormat appendString: @"\n"];
    }

    NSString* notes = self.notes;

    if (notes != nil) {
        [textFormat appendString: [notes stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [textFormat appendString: @"\n\n"];
    }
    
    int otherCost = [self.additionalPoints intValue];
    if (otherCost != 0) {
        NSString* otherCostString = [NSString stringWithFormat: @"Other cost: %d\n\n", otherCost];
        [textFormat appendString: otherCostString];
    }

    [textFormat appendString: [NSString stringWithFormat: @"Fleet total: %d\n\n", self.cost]];
    [textFormat appendString: NSLocalizedStringFromTable(@"Generated by Space Dock", @"platform", "")];

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
        } else if (![self canShip:ship.ship beWithShip:theShip]) {
            return ship;
        }
    }
    return nil;
}

-(BOOL)canShip:(DockShip*)shipA beWithShip:(DockShip*)shipB
{
    BOOL (^compare)(NSString*,NSString*) = ^(NSString* a,NSString* b) {
        if ([a isEqualToString:@"korok_s_bird_of_prey_71512"] && [b isEqualToString:@"assimilated_vessel_80279_71512"]) {
            return NO;
        } else if ([a isEqualToString:@"trager_71513b"] && [b isEqualToString:@"assimilated_vessel_64758_71513b"]) {
            return NO;
        }
        return YES;
    };
    if (compare(shipA.externalId,shipB.externalId) && compare(shipB.externalId,shipA.externalId)) {
        if ([shipA.title isEqualToString:shipB.title]) {
            if (shipA.isUnique && shipB.isUnique) {
                return NO;
            } else if (shipA.isMirrorUniverseUnique && shipB.isMirrorUniverseUnique) {
                return NO;
            } else {
                return YES;
            }
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

-(NSDictionary*)asJSON
{
    NSMutableDictionary* selfData = [[NSMutableDictionary alloc] init];
    [selfData setNonNilObject: self.resource.externalId forKey: @"resource"];
    [selfData setNonNilObject: self.name forKey: @"name"];
    [selfData setNonNilObject: self.additionalPoints forKey: @"additionalPoints"];
    [selfData setNonNilObject: [NSNumber numberWithInt: self.cost] forKey: @"cost"];
    [selfData setNonNilObject: self.notes forKey: @"notes"];
    [self maybeAssignNewUUID];
    [selfData setNonNilObject: self.uuid forKey: @"uuid"];
    [selfData setNonNilObject: self.modifiedAsString forKey: @"modified"];
    NSOrderedSet* ships = self.equippedShips;
    if (ships.count > 0) {
        NSMutableArray* shipsArray = [[NSMutableArray alloc] initWithCapacity: ships.count];
        for (DockEquippedShip* equippedShip in ships) {
            if (!equippedShip.isFighterSquadron) {
                [shipsArray addObject: [equippedShip asJSON]];
            }
        }
        [selfData setNonNilObject: shipsArray forKey: @"ships"];
    }
    return [NSDictionary dictionaryWithDictionary: selfData];
}

-(NSData*)asJSONData
{
    NSError* error;
    NSDictionary* json = [self asJSON];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject: json options: NSJSONWritingPrettyPrinted error: &error];
    return jsonData;
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

-(DockEquippedUpgrade*)containsUniqueUpgradeWithName:(NSString*)theName
{
    for (DockEquippedShip* ship in self.equippedShips) {
        DockEquippedUpgrade* existing = [ship containsUniqueUpgradeWithName: theName];

        if (existing) {
            return existing;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)containsMirrorUniverseUniqueUpgradeWithName:(NSString*)theName
{
    for (DockEquippedShip* ship in self.equippedShips) {
        DockEquippedUpgrade* existing = [ship containsMirrorUniverseUniqueUpgradeWithName: theName];

        if (existing) {
            return existing;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)containsUpgradeWithSpecial:(NSString*)special
{
    for (DockEquippedShip* ship in self.equippedShips) {
        DockEquippedUpgrade* existing = [ship containsUpgradeWithSpecial: special];

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
    DockSquad* squad = [DockSquad squad: context];
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
    if (captain.isAdmiral) {
        return [self canAddAdmiral: (DockAdmiral*)captain toShip: targetShip error: error];
    }

    if (targetShip.captainCount < 1) {
        if (error) {
            NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected ship.", captain.title];
            NSString* info = @"The selected ship has no slot for a captain.";
            NSDictionary* d = @{
                NSLocalizedDescriptionKey: msg,
                NSLocalizedFailureReasonErrorKey: info
            };
            *error = [NSError errorWithDomain: DockErrorDomain code: kUniqueConflict userInfo: d];
        }

        return NO;
    }
    
    if ([captain.title isEqualToString: @"Hugh"]) {
        if ([targetShip.squad containsUpgradeWithSpecial: @"not_with_hugh"] != nil) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"The squadron has an item that cannot be deployed with Hugh.";
                NSDictionary* d = @{
                    NSLocalizedDescriptionKey: msg,
                    NSLocalizedFailureReasonErrorKey: info
                };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }
    
    if ([captain.special isEqualToString: @"not_with_hugh"]) {
        if ([targetShip.squad containsUpgradeWithName:@"Hugh"] != nil) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"This captain cannot be deployed to a squadron with Hugh.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }

    if ([captain.title isEqualToString: @"Jean-Luc Picard"]) {
        if ([targetShip.squad containsUpgradeWithSpecial: @"not_with_jean_luc_picard"] != nil) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"The squadron has an item that cannot be deployed with Jean Luc Picard.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }
    
    if ([captain.special isEqualToString: @"not_with_jean_luc_picard"]) {
        if ([targetShip.squad containsUpgradeWithName:@"Jean-Luc Picard"] != nil) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"This captain cannot be deployed to a squadron with Jean Luc Picard.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }
    if ([targetShip.ship.shipClass isEqualToString:@"Romulan Drone Ship"]) {
        if (![targetShip.captain.externalId isEqualToString:@"gareb_71536"] && ![captain.externalId isEqualToString:@"gareb_71536"] && ![captain.externalId isEqualToString:@"romulan_drone_pilot_71536"] && ![captain.externalId isEqualToString:@"jhamel_72939"]) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected ship.", captain.title];
                NSString* info = @"This ship may only be assigned Gareb or a Romulan Drone Pilot as its Captain.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        } else {
            return [self passesUniquenessCheck: captain toShip: targetShip error: error];
        }
    } else if ([captain.externalId isEqualToString:@"gareb_71536"] && !targetShip.isResourceSideboard) {
        if (error) {
            NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected ship.", captain.title];
            NSString* info = @"Gareb may only be purchased for a Romulan Drone Ship.";
            NSDictionary* d = @{
                                NSLocalizedDescriptionKey: msg,
                                NSLocalizedFailureReasonErrorKey: info
                                };
            *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
        }
        return NO;
    } else if ([captain.externalId isEqualToString:@"romulan_drone_pilot_71536"] && !targetShip.isResourceSideboard) {
        if (error) {
            NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected ship.", captain.title];
            NSString* info = @"Romulan Drone Pilot may only be purchased for a Romulan Drone Ship.";
            NSDictionary* d = @{
                                NSLocalizedDescriptionKey: msg,
                                NSLocalizedFailureReasonErrorKey: info
                                };
            *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
        }
        return NO;
    } else if ([captain.externalId isEqualToString:@"jhamel_72939"] && !targetShip.isResourceSideboard) {
        if (error) {
            NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected ship.", captain.title];
            NSString* info = @"Jhamel may only be purchased for a Romulan Drone Ship.";
            NSDictionary* d = @{
                                NSLocalizedDescriptionKey: msg,
                                NSLocalizedFailureReasonErrorKey: info
                                };
            *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
        }
        return NO;
    }
    
    if ([captain.special isEqualToString: @"OnlyRomulanShip"]) {
        if (![targetShip.ship isRomulan]) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"This captain can only be deployed to a Romulan ship.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }
    
    if ([captain.special isEqualToString: @"OnlyFerengiShip"]) {
        if (![targetShip.ship isFerengi]) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"This captain can only be deployed to a Ferengi ship.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }

    if ([captain.special isEqualToString: @"OnlySpecies8472Ship"]) {
        if (![targetShip.ship isSpecies8472]) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"This captain can only be deployed to a Species 8472 ship.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }
    
    if ([targetShip containsUpgradeWithId:@"romulan_hijackers_71802"] != nil) {
        if (![captain isRomulan]) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", captain.title];
                NSString* info = @"You may only deploy a Romulan captain while this ship is equipped with the Romulan Hijackers Upgrade.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }
    DockCaptain* existingCaptain = [targetShip captain];

    if (captain == existingCaptain) {
        return YES;
    }

    return [self passesUniquenessCheck: captain toShip: targetShip error: error];
}

-(BOOL)canAddAdmiral:(DockAdmiral*)admiral toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    if ([admiral.special isEqualToString: @"OnlyRomulanShip"]) {
        if (![targetShip.ship isRomulan]) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", admiral.title];
                NSString* info = @"This admiral can only be deployed to a Romulan ship.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }
    
    if ([admiral.special isEqualToString: @"OnlyFerengiShip"]) {
        if (![targetShip.ship isFerengi]) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", admiral.title];
                NSString* info = @"This admiral can only be deployed to a Ferengi ship.";
                NSDictionary* d = @{
                                    NSLocalizedDescriptionKey: msg,
                                    NSLocalizedFailureReasonErrorKey: info
                                    };
                *error = [NSError errorWithDomain: DockErrorDomain code: kIllegalUpgrade userInfo: d];
            }
            return NO;
        }
    }
    
    if (targetShip.admiralCount < 1) {
        if (error) {
            NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected ship.", admiral.title];
            NSString* info = @"The selected ship has no slot for an admiral.";
            NSDictionary* d = @{
                NSLocalizedDescriptionKey: msg,
                NSLocalizedFailureReasonErrorKey: info
            };
            *error = [NSError errorWithDomain: DockErrorDomain code: kUniqueConflict userInfo: d];
        }

        return NO;
    }
    
    DockEquippedUpgrade* existingInstalledAdmiral = [self equippedAdmiral];
    DockAdmiral* existingAdmiral = (DockAdmiral*)[existingInstalledAdmiral upgrade];

    if (admiral == existingAdmiral) {
        return YES;
    }

    return [self passesUniquenessCheck: admiral toShip: targetShip error: error];
}

-(DockEquippedUpgrade*)addAdmiral:(DockAdmiral*)admiral toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    if (![self canAddAdmiral: admiral toShip: targetShip error: error]) {
        return nil;
    }

    for (DockEquippedShip* ship in self.equippedShips) {
        [ship removeAdmiral];
    }
    
    return [targetShip addAdmiral: admiral];
}

-(BOOL)canAddFleetCaptain:(DockFleetCaptain*)fleetCaptain toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    if (![targetShip canAddFleetCaptain: fleetCaptain error: error]) {
        return NO;
    }
    
    DockEquippedUpgrade* existingInstalledFleetCaptain = [self equippedFleetCaptain];
    DockFleetCaptain* existingFleetCaptain = (DockFleetCaptain*)[existingInstalledFleetCaptain upgrade];

    if (fleetCaptain == existingFleetCaptain) {
        return YES;
    }

    return YES;
}

-(DockEquippedUpgrade*)addFleetCaptain:(DockFleetCaptain*)fleetCaptain toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    if (![self canAddFleetCaptain: fleetCaptain toShip: targetShip error: error]) {
        return nil;
    }

    DockResource* resource = [fleetCaptain associatedResource];
    self.resource = resource;

    DockEquippedUpgrade* existingInstalledFleetCaptain = [self equippedFleetCaptain];
    if (existingInstalledFleetCaptain) {
        [existingInstalledFleetCaptain.equippedShip removeUpgrade: existingInstalledFleetCaptain];
    }

    return [targetShip addUpgrade: fleetCaptain];
}

-(BOOL)canAddOfficer:(DockOfficer*)officer toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    NSArray* crewUpgrades = [targetShip allUpgradesOfFaction: nil upType: @"Crew"];
    NSInteger crewCount = crewUpgrades.count;
    NSArray* officers = [targetShip allUpgradesOfFaction: nil upType: kOfficerUpgradeType];
    NSInteger limit = [targetShip officerLimit];
    if (officers.count >= limit) {
        if (error) {
            NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", officer.title];
            NSString* info = nil;
            if (crewCount > 0) {
                info = [NSString stringWithFormat: @"This ship has %d crew and can install no more than %d officer cards.", (int)crewCount, (int)limit];
            } else {
                info = @"Officers must be installed with crew and this ship has no crew ";
            }
            NSDictionary* d = @{
                NSLocalizedDescriptionKey: msg,
                NSLocalizedFailureReasonErrorKey: info
            };
            *error = [NSError errorWithDomain: DockErrorDomain code: kUniqueConflict userInfo: d];
        }

        return NO;
    }
    return [self passesUniquenessCheck: officer toShip: targetShip error: error];
}

-(DockEquippedUpgrade*)addOfficer:(DockOfficer*)officer toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    if (![self canAddOfficer: officer toShip: targetShip error: error]) {
        return nil;
    }

    DockResource* resource = [officer associatedResource];
    self.resource = resource;

    return [targetShip addUpgrade: officer];
}

-(BOOL)passesUniquenessCheck:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)targetShip error:(NSError**)error
{
    if ([upgrade isUnique]) {
        DockEquippedUpgrade* existing = [self containsUniqueUpgradeWithName: upgrade.title];

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
    if ([upgrade isMirrorUniverseUnique]) {
        DockEquippedUpgrade* existing = [self containsMirrorUniverseUniqueUpgradeWithName: upgrade.title];

        if (existing) {
            if (error) {
                NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", upgrade.title];
                NSString* info = [NSString stringWithFormat: @"This %@ is Mirror Universe unique and one with the same name already exists in the squadron.", upgrade.upType];
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
    if (upgrade.isAdmiral) {
        return [self canAddAdmiral: (DockAdmiral*)upgrade toShip: targetShip error: error];
    }
    if (upgrade.isCaptain) {
        return [self canAddCaptain: (DockCaptain*)upgrade toShip: targetShip error: error];
    }
    if (upgrade.isOfficer) {
        return [self canAddOfficer: (DockOfficer*)upgrade toShip: targetShip error: error];
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

    return [self passesUniquenessCheck: upgrade toShip: targetShip error: error];
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

-(DockEquippedShip*)getFighterSquadron
{
    DockEquippedShip* s = nil;

    for (DockEquippedShip* target in self.equippedShips) {
        if (target.isFighterSquadron) {
            s = target;
            break;
        }
    }
    return s;
}

-(DockEquippedShip*)addFighterSquadron:(DockResource*)resource
{
    DockEquippedShip* s = [self getFighterSquadron];
    if (s == nil) {
        DockShip* fighters = [resource associatedShip];
        s = [DockEquippedShip equippedShipWithShip: fighters];
        [self addEquippedShip: s];
    }
    return s;
}

-(DockEquippedShip*)removeFighterSquadron
{
    DockEquippedShip* s = [self getFighterSquadron];

    if (s) {
        [self removeEquippedShip: s];
    }

    return s;
}

-(DockEquippedUpgrade*)removeFleetCaptain
{
    DockEquippedUpgrade* eu = [self equippedFleetCaptain];

    if (eu) {
        [eu.equippedShip removeUpgrade: eu];
    }

    return eu;
}

-(void)removeOfficers
{
    DockUpgrade* first = [DockUpgrade upgradeForId:@"first_officer_collectiveop3" context:self.managedObjectContext];
    DockUpgrade* tactical = [DockUpgrade upgradeForId:@"tactical_officer_collectiveop3" context:self.managedObjectContext];
    DockUpgrade* ops = [DockUpgrade upgradeForId:@"operations_officer_collectiveop3" context:self.managedObjectContext];
    DockUpgrade* science = [DockUpgrade upgradeForId:@"science_officer_collectiveop3" context:self.managedObjectContext];
    
    [self purgeUpgrade:first];
    [self purgeUpgrade:tactical];
    [self purgeUpgrade:ops];
    [self purgeUpgrade:science];
}


-(void)setResource:(DockResource*)resource
{
    DockResource* oldResource = [self primitiveValueForKey: @"resource"];
    
    if (oldResource != resource) {

        if ([oldResource isSideboard]) {
            [self removeSideboard];
        } else if ([oldResource isFlagship]) {
            [self removeFlagship];
        } else if ([oldResource isFighterSquadron]) {
            [self removeFighterSquadron];
        } else if ([oldResource isFleetCaptain]) {
            [self removeFleetCaptain];
        } else if ([oldResource isOfficerCards]) {
            [self removeOfficers];
        }

        [self willChangeValueForKey: @"resource"];
        [self setPrimitiveValue: resource forKey: @"resource"];
        [self didChangeValueForKey: @"resource"];
        [resource addSquadObject: self];

        if ([resource isSideboard]) {
            [self addSideboard];
        } else if ([resource isFighterSquadron]) {
            [self addFighterSquadron: resource];
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

-(BOOL)flagshipIsNotAssigned
{
    if ([self.resource isFlagship]) {
        if (self.flagship == nil) {
            return YES;
        }
    }
    return NO;
}

-(DockEquippedUpgrade*)equippedAdmiral
{
    for (DockEquippedShip* equippedShip in self.equippedShips) {
        DockEquippedUpgrade* equippedAdmiral = equippedShip.equippedAdmiral;
        if (equippedAdmiral != nil) {
            return equippedAdmiral;
        }
    }
    return nil;
}

-(DockEquippedUpgrade*)equippedFleetCaptain
{
    for (DockEquippedShip* equippedShip in self.equippedShips) {
        DockEquippedUpgrade* e = equippedShip.equippedFleetCaptain;
        if (e != nil) {
            return e;
        }
    }
    return nil;
}


-(void)purgeUpgrade:(DockUpgrade*)upgrade
{
    for (DockEquippedShip* equippedShip in self.equippedShips) {
        [equippedShip purgeUpgrade: upgrade];
    }
}

-(NSString*)modifiedAsString
{
    NSDate* modified = self.modified;
    if (modified == nil) {
        modified = [NSDate date];
    }
    ISO8601DateFormatter* formatter = [[ISO8601DateFormatter alloc] init];
    formatter.includeTime = YES;
    return [formatter stringFromDate: modified];
}

-(void)setModifiedAsString:(NSString *)modifiedAsString
{
    if (modifiedAsString == nil) {
        self.modified = [NSDate date];
    } else {
        ISO8601DateFormatter* formatter = [[ISO8601DateFormatter alloc] init];
        self.modified = [formatter dateFromString: modifiedAsString];
    }
}

@end
