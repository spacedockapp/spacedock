#import "DockSetItem+Addons.h"

#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
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

-(NSString*)setName
{
    NSSet* sets = self.sets;
    NSInteger setsCount = sets.count;
    if (setsCount == 0) {
        return @"";
    } else if (setsCount == 1) {
        return [[sets anyObject] productName];
    }
    
    NSMutableArray* allSetNames = [[NSMutableArray alloc] initWithCapacity: setsCount];
    for (DockSet* set in sets) {
        [allSetNames addObject: set.productName];
    }
    return [allSetNames componentsJoinedByString: @", "];
}

-(NSString*)itemDescription
{
    return [self description];
}

-(NSString*)faction
{
    return @"";
}

-(NSString*)sortStringForSet
{
    return [self valueForKey: @"faction"];
}

-(NSComparisonResult)compareForSet:(id)object
{
    return [[self sortStringForSet] compare: [object sortStringForSet]];
}

@end
