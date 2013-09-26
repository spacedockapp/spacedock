#import "DockUpgrade+Addons.h"

@implementation DockUpgrade (Addons)

-(NSString*)description
{
    return [NSString stringWithFormat: @"%@ (%@)", self.title, self.upType];
}

-(NSComparisonResult)compareTo:(DockUpgrade*)other
{
    NSString* upTypeMe = self.upType;
    NSString* upTypeOther = other.upType;
    NSComparisonResult r = [upTypeMe compare:upTypeOther];
    if (r == NSOrderedSame) {
        return [self.title caseInsensitiveCompare: other.title];
    }

    if ([upTypeMe isEqualToString: @"Captain"]) {
        return NSOrderedAscending;
    }

    if ([upTypeOther isEqualToString: @"Captain"]) {
        return NSOrderedDescending;
    }

    return r;
}

@end
