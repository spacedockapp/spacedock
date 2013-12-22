#import "DockSetItem+Addons.h"

#import "DockSet+Addons.h"

@implementation DockSetItem (Addons)

-(NSString*)anySetExternalId
{
    DockSet* set = [self.sets anyObject];
    return set.externalId;
}

@end
