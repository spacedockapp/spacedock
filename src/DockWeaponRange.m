#import "DockWeaponRange.h"

@implementation DockWeaponRange

-(id)initWithString:(NSString*)range
{
    self = [super init];
    if (self != nil) {
        NSCharacterSet* rangeSep = [NSCharacterSet characterSetWithCharactersInString: @" -"];
        NSArray* parts = [range componentsSeparatedByCharactersInSet: rangeSep];
        if (parts.count > 0) {
            _range.location = [parts[0] intValue];
            if (parts.count > 1) {
                _range.length = [parts[1] intValue] - _range.location;
            }
        }
    }
    return self;
}

-(NSComparisonResult)compare:(DockWeaponRange*)other
{
    if (NSEqualRanges(_range, other.range)) {
        return NSOrderedSame;
    }
    
    NSUInteger minA = _range.location;
    NSUInteger maxA = NSMaxRange(_range);
    NSUInteger minB = other.range.location;
    NSUInteger maxB = NSMaxRange(other.range);
    if (maxA == maxB) {
        if (minB > minA) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }
    if (maxA > maxB) {
        return NSOrderedDescending;
    }
    return NSOrderedAscending;
}

@end
