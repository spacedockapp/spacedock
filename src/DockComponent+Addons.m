#import "DockComponent+Addons.h"

#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockUtils.h"

@implementation DockComponent (Addons)

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

-(NSString*)sortStringForSet
{
    @try {
        return [self valueForKey: @"faction"];
    } @catch (NSException *exception) {
    } @finally {
    }
    return @"";
}

-(NSComparisonResult)compareForSet:(id)object
{
    return [[self sortStringForSet] compare: [object sortStringForSet]];
}

-(NSString*)setCode
{
    DockSet* set = self.sets.anyObject;
    return set.setCode;
}

@end
