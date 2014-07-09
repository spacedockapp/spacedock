#import "DockAdmiral+Addons.h"

@implementation DockAdmiral (Addons)

-(NSString*)upType
{
    return @"Admiral";
}

-(int)admiralTalentCount
{
    return [self.admiralTalent intValue];
}

@end
