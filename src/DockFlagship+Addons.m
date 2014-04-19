#import "DockFlagship+Addons.h"

#import "DockShip+Addons.h"

@implementation DockFlagship (Addons)

+(DockFlagship*)flagshipForId:(NSString*)flagshipId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Flagship" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"externalId == %@", flagshipId];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

-(int)talentAdd
{
    return [self.talent intValue];
}

-(int)techAdd
{
    return [self.tech intValue];
}

-(int)weaponAdd
{
    return [self.weapon intValue];
}

-(int)crewAdd
{
    return [self.crew intValue];
}

-(int)agilityAdd
{
    return [self.agility intValue];
}

-(int)hullAdd
{
    return [self.hull intValue];
}

-(int)attackAdd
{
    return [self.attack intValue];
}

-(int)shieldAdd
{
    return [self.shield intValue];
}

-(NSNumber*)borg
{
    return @0;
}

-(NSString*)capabilities
{
    NSMutableArray* caps = [[NSMutableArray alloc] initWithCapacity: 0];
    
    NSDictionary* capsToCheck = @{
        @"tech" : @"Tech",
        @"weapon" : @"Weap",
        @"crew" : @"Crew",
        @"borg" : @"Borg",
        @"talent": @"Tale",
        @"sensorEcho": @"Echo",
        @"evasiveManeuvers": @"EvaM",
        @"scan": @"Scan",
        @"targetLock": @"Lock",
        @"battleStations": @"BatS",
        @"cloak": @"Clk"
    };
    
    for (NSString* key in [capsToCheck.allKeys sortedArrayUsingSelector: @selector(compare:)]) {
        NSNumber* n = [self valueForKey: key];
        int v = [n intValue];
        if (v > 0) {
            NSString* label = capsToCheck[key];
            [caps addObject: [NSString stringWithFormat: @"%@: %d", label, v]];
        }
    }

    return [caps componentsJoinedByString: @" "];
}

-(NSString*)name
{
    if ([self.faction isEqualToString: @"Independent"]) {
        return self.title;
    }
    return self.faction;
}

-(NSString*)plainDescription
{
    return [NSString stringWithFormat: @"Flagship: %@", self.title];
}

-(BOOL)compatibleWithShip:(DockShip*)targetShip
{
    if (targetShip.isFighterSquadron) {
        return NO;
    }
    
    NSString* myFaction = self.faction;
    
    if ([myFaction isEqualToString: @"Independent"]) {
        return YES;
    }
    
    return [myFaction isEqualToString: targetShip.faction];
}

-(BOOL)isFighterSquadron
{
    return NO;
}

-(NSString*)itemDescription
{
    return [self plainDescription];
}

@end
