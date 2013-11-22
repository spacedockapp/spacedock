#import "DockManeuver+Addons.h"

@implementation DockManeuver (Addons)

-(NSString*)asString
{
    return [NSString stringWithFormat: @"%@:%@:%@", self.speed, self.kind, self.color];
}

-(NSComparisonResult)compareTo:(DockManeuver*)other
{
    return [[self asString] compare: [other asString]];
}

@end
