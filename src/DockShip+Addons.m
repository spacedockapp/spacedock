#import "DockShip+Addons.h"

#import "DockManeuver.h"
#import "DockShipClassDetails+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"

@implementation DockShip (Addons)

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

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

-(NSString*)formattedClass
{
    return [NSString stringWithFormat: @"%@ Class", self.shipClass];
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
    if ([[self title] isEqualToString: self.shipClass]) {
        return self.title;
    }

    return [NSString stringWithFormat: @"%@ (%@)", self.title, self.shipClass];
}

-(NSAttributedString*)styledDescription
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: [self plainDescription]];
#if TARGET_OS_IPHONE
#else
    NSAttributedString* space = [[NSAttributedString alloc] initWithString: @" "];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.attack stringValue], [NSColor whiteColor], [NSColor redColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.agility stringValue], [NSColor blackColor], [NSColor greenColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.hull stringValue], [NSColor blackColor], [NSColor yellowColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.shield stringValue], [NSColor whiteColor], [NSColor blueColor])];
#endif
    return desc;
}

-(NSString*)factionCode
{
    return [[self faction] substringToIndex: 1];
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

    return [NSArray arrayWithArray: actionStringParts];
}

-(void)updateShipClass:(NSString*)newShipClass
{
    if (self.shipClassDetails == nil || ![self.shipClass isEqualToString: newShipClass]) {
        self.shipClass = newShipClass;
        DockShipClassDetails* details = [DockShipClassDetails find: newShipClass context: self.managedObjectContext];
        if (details != nil) {
            self.shipClassDetails = details;
        } else {
            NSLog(@"failed to find class %@", newShipClass);
        }
    }
}

@end
