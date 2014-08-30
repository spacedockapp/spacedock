#import "DockComponent+Addons.h"

#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockTagged+Addons.h"
#import "DockUtils.h"

NSString* kDockFactionCategoryType = @"faction";
NSString* kDockTypeCategoryType = @"type";

@implementation DockComponent (Addons)

#pragma mark - Factions

-(NSSet*)factions
{
    return [self valuesForCategoriesOfType: kDockFactionCategoryType];
}

-(NSArray*)factionsSortedByInitiative
{
    NSArray* factionOrder = @[
        @"Federation",
        @"Klingon",
        @"Romulan",
        @"Dominion",
        @"Borg",
        @"Species 8472",
        @"Kazon",
        @"Bajoran",
        @"Ferengi",
        @"Vulcan",
        @"Independent",
        @"Mirror Universe"
    ];
    
    id factionCompare = ^(id obj1, id obj2) {
        NSInteger index1 = [factionOrder indexOfObject: obj1];
        NSInteger index2 = [factionOrder indexOfObject: obj2];
        if (index1 < index2) {
            return NSOrderedAscending;
        }
        if (index1 > index2) {
            return NSOrderedDescending;
        }
        return [obj1 compare: obj2];
    };
    
    NSArray* sorted = [[[self factions] allObjects] sortedArrayUsingComparator: factionCompare];
    return sorted;
}

-(NSString*)highestFaction
{
    return [[self factionsSortedByInitiative] firstObject];
}

-(NSString*)faction
{
    return [self highestFaction];
}

-(NSString*)combinedFactions
{
    return [[self factionsSortedByInitiative] componentsJoinedByString: @", "];
}

-(BOOL)hasFaction:(NSString*)faction
{
    return [self hasCategoryType: kDockFactionCategoryType withValue: faction];
}

-(NSString*)factionCode
{
    return factionCode(self);
}

#pragma mark - Types

-(NSSet*)types
{
    return [self valuesForCategoriesOfType: kDockTypeCategoryType];
}

-(BOOL)hasType:(NSString*)type
{
    return [self hasCategoryType: kDockTypeCategoryType withValue: type];
}

-(NSString*)combinedTypes
{
    return [[[self types] allObjects] componentsJoinedByString: @", "];
}


#pragma mark - Sets

-(NSString*)anySetExternalId
{
    DockSet* set = [self.sets anyObject];
    return set.externalId;
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
