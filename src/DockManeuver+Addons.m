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

-(BOOL)isSpin
{
    return [self.kind hasSuffix: @"spin"];
}

-(BOOL)isFlank
{
    return [self.kind hasSuffix: @"flank"];
}

-(BOOL)isComeAbout
{
    return [self.kind isEqualToString: @"about"];
}
@end
