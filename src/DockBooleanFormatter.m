#import "DockBooleanFormatter.h"

@implementation DockBooleanFormatter

-(NSString*)stringForObjectValue:(id)obj
{
    BOOL yn = [obj boolValue];

    if (yn) {
        return @"Y";
    }

    return @"N";
}

@end
