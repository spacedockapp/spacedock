#import "NSString+Addons.h"

@implementation NSString (Addons)

-(NSComparisonResult)compareDegrees:(NSString *)string
{
    int a = [self intValue];
    int b = [string intValue];
    if (a == b) {
        return NSOrderedSame;
    }
    
    if (a > b) {
        return NSOrderedAscending;
    }
    
    return NSOrderedDescending;
}

@end
