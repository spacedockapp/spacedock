#import "DockSetItem+Addons.h"

#import "DockSet+Addons.h"
#import "DockUtils.h"

@implementation DockSetItem (Addons)

-(NSString*)anySetExternalId
{
    DockSet* set = [self.sets anyObject];
    return set.externalId;
}

-(NSString*)factionCode
{
    return factionCode(self);
}

@end
