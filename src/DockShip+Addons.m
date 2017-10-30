#import "DockShip+Addons.h"

#import "DockManeuver.h"
#import "DockResource+Addons.h"
#import "DockSetItem+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"

@implementation DockShip (Addons)

+(NSSet*)keyPathsForValuesAffectingActionString
{
    return [NSSet setWithObjects:
        @"battleStations",
        @"cloak",
        @"evasiveManeuvers",
        @"regenerate",
        @"scan",
        @"sensorEcho",
        @"targetLock",
    nil];
}


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
    if (!self.isAnyKindOfUnique) {
        return self.shipClass;
    }
    
    if ([self.externalId isEqualToString:@"maquis_starship_71528"]) {
        return [NSString stringWithFormat: @"%@ (Rear Arc)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"1033"] || [self.externalId isEqualToString:@"1043"]) {
        return [NSString stringWithFormat:@"%@ (2 Weapons)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"1004"] || [self.externalId isEqualToString:@"romulan_starship_71278"]) {
        return [NSString stringWithFormat:@"%@ (2 Crew)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"romulan_starship_71794"]) {
        return [NSString stringWithFormat:@"%@ (2 Weapons/2 Crew)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"federation_starship_71280"]) {
        return [NSString stringWithFormat:@"%@ (2 Crew)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"federation_starship_72001p"]) {
        return [NSString stringWithFormat:@"%@ (2 Weapons)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"1049"]) {
        return [NSString stringWithFormat:@"%@ (2 Crew)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"federation_starship_72011"]) {
        return [NSString stringWithFormat:@"%@ (2 Weapons)", self.shipClass];
    }

    return self.title;
}

-(NSString*)descriptiveTitle
{
    if (self.isAnyKindOfUnique) {
        if ([self.externalId isEqualToString:@"sakharov_c_71997p"]) {
            return [NSString stringWithFormat:@"%@ (Extra Crew)", self.title];
        } else if ([self.externalId isEqualToString:@"sakharov_71997p"]) {
            return [NSString stringWithFormat:@"%@ (Extra Tech)", self.title];
        } else if ([self.shipClassDetails.externalId isEqualToString:@"constitution_refit_class"]) {
            return [NSString stringWithFormat:@"%@ (Refit)", self.title];
        }
        return self.title;
    }

    if ([self.externalId isEqualToString:@"maquis_starship_71528"]) {
        return [NSString stringWithFormat: @"%@ (Rear Arc)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"1033"] || [self.externalId isEqualToString:@"1043"]) {
        return [NSString stringWithFormat:@"%@ (2 Weapons)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"1004"] || [self.externalId isEqualToString:@"romulan_starship_71278"]) {
        return [NSString stringWithFormat:@"%@ (2 Crew)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"romulan_starship_71794"]) {
        return [NSString stringWithFormat:@"%@ (2 Weapons/2 Crew)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"federation_starship_71280"]) {
        return [NSString stringWithFormat:@"%@ (2 Crew)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"federation_starship_72001p"]) {
        return [NSString stringWithFormat:@"%@ (2 Weapons)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"1049"]) {
        return [NSString stringWithFormat:@"%@ (2 Crew)", self.shipClass];
    } else if ([self.externalId isEqualToString:@"federation_starship_72011"]) {
        return [NSString stringWithFormat:@"%@ (2 Weapons)", self.shipClass];
    } else if ([self.shipClassDetails.externalId isEqualToString:@"constitution_refit_class"]) {
        return [NSString stringWithFormat:@"%@ (Refit)", self.shipClass];
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

-(BOOL)isBattleship
{
    NSRange r = [self.shipClass rangeOfString: @"Battleship" options: NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
}

-(BOOL)isRomulanScienceVessel
{
    return [self.shipClass isEqualToString: @"Romulan Science Vessel"];
}

-(BOOL)isRemanWarbird
{
    return [self.shipClass isEqualToString: @"Reman Warbird"];
}

-(BOOL)isTholian
{
    NSRange r = [self.shipClass rangeOfString: @"Tholian" options: NSCaseInsensitiveSearch];
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

-(BOOL)isMirrorUniverseUnique
{
    return [self.mirrorUniverseUnique boolValue];
}

-(BOOL)isAnyKindOfUnique
{
    return self.isUnique || self.isMirrorUniverseUnique;
}

-(BOOL)isFederation
{
    if (targetHasFaction(@"Vulcan",self) || targetHasFaction(@"Bajoran",self)) {
        return YES;
    }
    return targetHasFaction(@"Federation", self);
}

-(BOOL)isFerengi
{
    return targetHasFaction(@"Ferengi", self);
}

-(BOOL)isBajoran
{
    return targetHasFaction(@"Bajoran", self);
}

-(BOOL)isFighterSquadron
{
    if ([self.externalId isEqualToString: @"federation_attack_fighter_op6prize"]) {
        return YES;
    }
    if ([self.externalId isEqualToString: @"hideki_class_attack_fighter_op5prize"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isShuttle
{
    if ([self.shipClass isEqualToString: @"Type 7 Shuttlecraft"]) {
        return YES;
    }
    if ([self.shipClass isEqualToString: @"Ferengi Shuttle"]) {
        return YES;
    }
    if ([self.shipClass isEqualToString: @"Delta Flyer Class Shuttlecraft"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isSpecies8472
{
    return targetHasFaction(@"Species 8472",self);
}

-(BOOL)isKazon
{
    return targetHasFaction(@"Kazon",self);
}

-(BOOL)isBorg
{
    return targetHasFaction(@"Borg",self);
}

-(BOOL)isVoyager
{
    return [self.title isEqualToString: @"U.S.S. Voyager"];
}

-(BOOL)isBajoranInterceptor
{
    return [self.shipClass isEqualToString: @"Bajoran Interceptor"];
}

-(BOOL)isBattleshipOrCruiser
{
    NSString* shipClass = self.shipClass;
    return [shipClass isEqualToString: @"Jem'Hadar Battle Cruiser"] || [shipClass isEqualToString: @"Jem'Hadar Battleship"];
}

-(BOOL)isRaven
{
    return [self.title isEqualToString: @"U.S.S. Raven"];
}

-(BOOL)isScoutCube
{
    NSRange r = [self.shipClass rangeOfString: @"Scout Cube" options: NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
}

-(BOOL)isGalaxyClass
{
    NSRange r = [self.shipClass rangeOfString: @"Galaxy" options: NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
}

-(BOOL)isIntrepidClass
{
    NSRange r = [self.shipClass rangeOfString: @"Intrepid" options: NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
}

-(BOOL)isSovereignClass
{
    NSRange r = [self.shipClass rangeOfString: @"Sovereign" options: NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
}

-(BOOL)isKlingonBirdOfPrey
{
    return [self.shipClass isEqualToString: @"Klingon Bird-of-Prey"];
}

-(DockResource*)associatedResource
{
    if ([self.externalId isEqualToString: @"federation_attack_fighter_op6prize"]) {
        return [DockResource resourceForId: @"federation_attack_fighters_op6participation" context: self.managedObjectContext];
    }
    if ([self.externalId isEqualToString: @"hideki_class_attack_fighter_op5prize"]) {
        return [DockResource resourceForId: @"hideki_class_attack_squadron_op5participation" context: self.managedObjectContext];
    }
    NSLog(@"No associated resource for %@", self.externalId);
    return nil;
}

-(BOOL)isVulcan
{
    return targetHasFaction(@"Vulcan", self);
}

-(BOOL)isMirrorUniverse
{
    return targetHasFaction(@"Mirror Universe", self);
}

-(BOOL)isSuurokClass
{
    return [self.shipClass isEqualToString: @"Suurok Class"];
}

-(BOOL)isPredatorClass
{
    return [self.shipClass isEqualToString: @"Predator Class"];
}

-(BOOL)isIndependent
{
    if (targetHasFaction(@"Ferengi",self) || targetHasFaction(@"Kazon",self) || targetHasFaction(@"Xindi",self)) {
        return YES;
    }
    return targetHasFaction(@"Independent", self);
}

-(BOOL)isRomulan
{
    return targetHasFaction(@"Romulan", self);
}

-(BOOL)isKlingon
{
    return targetHasFaction(@"Klingon", self);
}

-(BOOL)isDominion
{
    return targetHasFaction(@"Dominion", self);
}

-(BOOL)isXindi
{
    return targetHasFaction(@"Xindi", self);
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

-(int)admiralCount
{
    if (self.isFighterSquadron) {
        return 0;
    }
    if (self.isShuttle) {
        return 0;
    }
    return 1;
}

-(int)fleetCaptainCount
{
    if (self.isFighterSquadron) {
        return 0;
    }
    return 1;
}

-(int)borgCount
{
    return [self.borg intValue];
}

-(int)squadronUpgradeCount
{
    return [self.squadronUpgrade intValue];
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
    return actionStrings(self);
}

-(NSString*)actionString
{
    return [[self actionStrings] componentsJoinedByString: @", "];
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

-(void)updateShipClassWithId:(NSString*)newShipClassId
{
    NSString* existingShipClassDetailsId = self.shipClassDetails.externalId;
    if (self.shipClassDetails == nil || ![newShipClassId isEqualToString: existingShipClassDetailsId]) {
        NSLog(@"updating ship class for ship %@", self.title);
        DockShipClassDetails* details = [DockShipClassDetails shipClassDetailsForId: newShipClassId context: self.managedObjectContext];

        if (details != nil) {
            self.shipClassDetails = details;
        } else {
            NSLog(@"failed to find class %@", newShipClassId);
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
    BOOL selfIsUnique = [self isAnyKindOfUnique];
    BOOL otherIsUnique = [otherShip isAnyKindOfUnique];
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

-(NSString*)combinedFactions
{
    return combinedFactionString(self);
}

-(NSString*)uniqueAsString
{
    return uniqueAsString(self);
}

@end
