#import "DockAdmiral+Addons.h"

#import "DockConstants.h"

@implementation DockAdmiral (Addons)

-(NSString*)upType
{
    return kAdmiralUpgradeType;
}

-(int)admiralTalentCount
{
    return [self.admiralTalent intValue];
}

-(int)additionalTalentSlots
{
    return [self.admiralTalent intValue];
}

@end
