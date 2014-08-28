#import "DockCategorized+Addons.h"

#import "DockCategory+Addons.h"

@implementation DockCategorized (Addons)

-(NSSet*)categoriesOfType:(NSString*)type
{
    id testCategoryType = ^(id obj, BOOL *stop) {
        DockCategory* category = obj;
        return [category.type isEqualToString: type];
    };
    
    return [self.categories objectsPassingTest: testCategoryType];
}

-(NSSet*)valuesForCategoriesOfType:(NSString*)type
{
    NSSet* categories = [self categoriesOfType: type];
    NSMutableSet* values = [[NSMutableSet alloc] initWithCapacity: categories.count];
    for (DockCategory* category in categories) {
        [values addObject: category.value];
    }
    return [NSSet setWithSet: values];
}

-(BOOL)hasCategoryType:(NSString*)type withValue:(NSString*)value
{
    NSSet* matchingTypes = [self valuesForCategoriesOfType: type];
    return [matchingTypes containsObject: value];
}

@end
