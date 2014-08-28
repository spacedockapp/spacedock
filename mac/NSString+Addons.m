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

-(NSArray*)strippedComponentsSeparatedByString:(NSString *)separator
{
    NSArray* unstripped = [self componentsSeparatedByString: separator];
    NSMutableArray* stripped = [[NSMutableArray alloc] initWithCapacity: unstripped.count];
    NSCharacterSet* ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSString* s in unstripped) {
        [stripped addObject: [s stringByTrimmingCharactersInSet: ws]];
    }
    return [NSArray arrayWithArray: stripped];
}

@end
