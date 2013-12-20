#import "DockFlagship+Addons.h"

#import "DockShip+Addons.h"

@implementation DockFlagship (Addons)

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

-(NSString*)capabilities
{
    NSMutableArray* caps = [[NSMutableArray alloc] initWithCapacity: 0];
    
    NSDictionary* capsToCheck = @{
        @"tech" : @"Tech",
        @"weapon" : @"Weap",
        @"crew" : @"Crew",
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

-(NSString*)plainDescription
{
    return [NSString stringWithFormat: @"Flagship: %@", self.title];
}

-(BOOL)compatibleWithShip:(DockShip*)targetShip
{
    NSString* myFaction = self.faction;
    
    if ([myFaction isEqualToString: @"Independent"]) {
        return YES;
    }
    
    return [myFaction isEqualToString: targetShip.faction];
}

@end
