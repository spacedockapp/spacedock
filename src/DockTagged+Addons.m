#import "DockTagged+Addons.h"

#import "DockTag+Addons.h"

@implementation DockTagged (Addons)

-(NSSet*)categoriesOfType:(NSString*)type
{
    NSString* categoryTypeTag = [DockTag categoryTag: type value: @""];
    id testCategoryType = ^(id obj, BOOL *stop) {
        DockTag* tag = obj;
        return [tag.value hasPrefix: categoryTypeTag];
    };
    
    return [self.tags objectsPassingTest: testCategoryType];
}

-(NSSet*)valuesForCategoriesOfType:(NSString*)type
{
    NSSet* categories = [self categoriesOfType: type];
    NSMutableSet* values = [[NSMutableSet alloc] initWithCapacity: categories.count];
    for (DockTag* categoryTag in categories) {
        NSString* categoryValue = [DockTag categoryValue: categoryTag.value];
        [values addObject: categoryValue];
    }
    return [NSSet setWithSet: values];
}

-(BOOL)hasCategoryType:(NSString*)type withValue:(NSString*)value
{
    NSSet* matchingTypes = [self valuesForCategoriesOfType: type];
    return [matchingTypes containsObject: value];
}
@end
