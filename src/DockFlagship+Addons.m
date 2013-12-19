#import "DockFlagship+Addons.h"

@implementation DockFlagship (Addons)

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

@end
