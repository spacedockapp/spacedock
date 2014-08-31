#import "DockTagged+Addons.h"

#import "DockTag+Addons.h"
#import "NSString+Addons.h"

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

-(void)parseAndAddTags:(NSString*)tagString
{
    NSArray* tags = [tagString strippedComponentsSeparatedByString: @","];
    for (NSString* oneTag in tags) {
        DockTag* tag = [DockTag findOrCreateTag:oneTag context: self.managedObjectContext];
        [self addTagsObject: tag];
    }
}

-(BOOL)hasTag:(NSString*)tagString
{
    id testCategoryType = ^(id obj, BOOL *stop) {
        DockTag* tag = obj;
        if ([tag.value isEqualToString: tagString]) {
            *stop = YES;
            return YES;
        }
        return NO;
    };
    
    return [[self.tags objectsPassingTest: testCategoryType] count] > 0;
}

@end
