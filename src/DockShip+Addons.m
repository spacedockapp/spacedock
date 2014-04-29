#import "DockShip+Addons.h"

#import "DockManeuver.h"
#import "DockResource+Addons.h"
#import "DockSetItem+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"

@implementation DockShip (Addons)

+(NSArray*)allShips:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Ship" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    return [context executeFetchRequest: request error: &err];
}

+(DockShip*)shipForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Ship" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"externalId == %@", externalId];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

-(DockShip*)counterpart
{
    NSManagedObjectContext* context = [self managedObjectContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Ship" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"(shipClass like[cd] %@) AND (unique != %@)", self.shipClass, self.unique];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    for (DockShip* ship in  existingItems) {
        if ([ship.anySetExternalId isEqualToString: self.anySetExternalId]) {
            return ship;
        }
    }

    return nil;
}

-(NSString*)formattedClass
{
    return self.shipClass;
}

NSString* asDegrees(NSString* textValue)
{
    if ([textValue length] == 0) {
        return @"";
    }

    return [NSString stringWithFormat: @"%@º", textValue];
}

-(NSString*)formattedFrontArc
{
    return asDegrees(self.shipClassDetails.frontArc);
}

-(NSString*)formattedRearArc
{
    return asDegrees(self.shipClassDetails.rearArc);
}

-(NSString*)capabilities
{
    NSMutableArray* caps = [[NSMutableArray alloc] initWithCapacity: 0];
    int v = [self techCount];

    if (v > 0) {
        [caps addObject: [NSString stringWithFormat: @"Tech: %d", v]];
    }

    v = [self weaponCount];

    if (v > 0) {
        [caps addObject: [NSString stringWithFormat: @"Weap: %d", v]];
    }

    v = [self crewCount];

    if (v > 0) {
        [caps addObject: [NSString stringWithFormat: @"Crew: %d", v]];
    }

    return [caps componentsJoinedByString: @" "];
}

-(NSString*)plainDescription
{
    if (!self.isUnique) {
        return self.shipClass;
    }

    return self.title;
}

-(NSString*)descriptiveTitle
{
    if (self.isUnique) {
        return self.title;
    }

    return self.shipClass;
}

-(BOOL)isBreen
{
    NSRange r = [self.shipClass rangeOfString: @"Breen" options: NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
}

-(BOOL)isJemhadar
{
    NSRange r = [self.shipClass rangeOfString: @"Jem'hadar" options: NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
}

-(BOOL)isKeldon
{
    NSRange r = [self.shipClass rangeOfString: @"Keldon" options: NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
}

-(BOOL)isRomulanScienceVessel
{
    return [self.shipClass isEqualToString: @"Romulan Science Vessel"];
}

-(BOOL)isDefiant
{
    return [self.title isEqualToString: @"U.S.S. Defiant"];
}

-(BOOL)isUnique
{
    return [self.unique boolValue];
}

-(BOOL)isFederation
{
    return [self.faction isEqualToString: @"Federation"];
}

-(BOOL)isBajoran
{
    return [self.faction isEqualToString: @"Bajoran"];
}

-(BOOL)isFighterSquadron
{
    NSString* shipClass = self.shipClass;
    if ([shipClass isEqualToString: @"Federation Attack Fighter"]) {
        return YES;
    }
    if ([shipClass isEqualToString: @"Hideki Class Attack Fighter"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isSpecies8472
{
    return [self.faction isEqualToString: @"Species 8472"];
}

-(BOOL)isKazon
{
    return [self.faction isEqualToString: @"Kazon"];
}

-(BOOL)isBorg
{
    return [self.faction isEqualToString: @"Borg"];
}

-(BOOL)isVoyager
{
    return [self.title isEqualToString: @"U.S.S. Voyager"];
}

-(DockResource*)associatedResource
{
    NSString* shipClass = self.shipClass;
    if ([shipClass isEqualToString: @"Federation Attack Fighter"]) {
        return [DockResource resourceForId: @"federation_attack_fighters_op6participation" context: self.managedObjectContext];
    }
    if ([shipClass isEqualToString: @"Hideki Class Attack Fighter"]) {
        return [DockResource resourceForId: @"hideki_class_attack_squadron_op5participation" context: self.managedObjectContext];
    }
    NSLog(@"No associated resource for %@", self);
    return nil;
}

-(int)techCount
{
    return [self.tech intValue];
}

-(int)weaponCount
{
    return [self.weapon intValue];
}

-(int)crewCount
{
    return [self.crew intValue];
}

-(int)captainCount
{
    return [self.captainLimit intValue];
}

-(int)borgCount
{
    return [self.borg intValue];
}

-(NSString*)attackString
{
    if ([self isFighterSquadron]) {
        int attackMax = [[self attack] intValue];
        return [NSString stringWithFormat: @"%d/%d/%d/%d", attackMax, attackMax-1, attackMax-2, attackMax-3];
    }
    return [NSString stringWithFormat: @"%@", self.attack];
}

-(NSString*)agilityString
{
    if ([self isFighterSquadron]) {
        return @"0/1/2/3";
    }
    return [NSString stringWithFormat: @"%@", self.agility];
}

-(NSArray*)actionStrings
{
    NSMutableArray* actionStringParts = [NSMutableArray arrayWithCapacity: 0];

    if ([self.scan intValue]) {
        [actionStringParts addObject: @"Scan"];
    }

    if ([self.cloak intValue]) {
        [actionStringParts addObject: @"Cloak"];
    }

    if ([self.battleStations intValue]) {
        [actionStringParts addObject: @"Battle"];
    }

    if ([self.evasiveManeuvers intValue]) {
        [actionStringParts addObject: @"Evade"];
    }

    if ([self.targetLock intValue]) {
        [actionStringParts addObject: @"Lock"];
    }

    if ([self.regenerate intValue]) {
        [actionStringParts addObject: @"Regen"];
    }

    return [NSArray arrayWithArray: actionStringParts];
}

-(void)updateShipClass:(NSString*)newShipClass
{
    if (self.shipClassDetails == nil || ![self.shipClass isEqualToString: newShipClass]) {
        NSLog(@"updating ship class for ship %@", self.title);
        self.shipClass = newShipClass;
        DockShipClassDetails* details = [DockShipClassDetails find: newShipClass context: self.managedObjectContext];

        if (details != nil) {
            self.shipClassDetails = details;
        } else {
            NSLog(@"failed to find class %@", newShipClass);
        }
    }
}

-(NSString*)movesSummary
{
    DockShipClassDetails* details = self.shipClassDetails;

    if (details == nil) {
        return @"";
    }

    return details.movesSummary;
}

-(NSComparisonResult)compareTo:(id)object
{
    if (![object isMemberOfClass: [DockShip class]]) {
        return NSOrderedDescending;
    }
    DockShip* otherShip = (DockShip*)object;
    BOOL selfIsUnique = [self isUnique];
    BOOL otherIsUnique = [otherShip isUnique];
    if (selfIsUnique == otherIsUnique) {
        return NSOrderedSame;
    }
    if (selfIsUnique) {
        return NSOrderedDescending;
    }
    return NSOrderedAscending;
}

-(NSString*)sortStringForSet
{
    return [NSString stringWithFormat: @"%@:a:%@:%@", self.faction, [self.unique boolValue] ? @"a" : @"z", self.title];
}

-(NSString*)itemDescription
{
    return self.title;
}


@end
