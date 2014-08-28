#import "DockCategory+Addons.h"

NSString* kDockCategoryEntityName = @"Category";

@implementation DockCategory (Addons)

+(DockCategory*)findOrCreateCategory:(NSString*)type value:(NSString*)value context:(NSManagedObjectContext*)context
{
    DockCategory* category = nil;
    NSEntityDescription* entity = [NSEntityDescription entityForName: kDockCategoryEntityName inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSString* pair = [DockCategory pair: type value: value];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"pair = %@", pair];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count == 0) {
        category = [[DockCategory alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
        category.value = value;
        category.type = type;
        category.pair = pair;
    } else {
        assert(existingItems.count == 1);
        category = existingItems[0];
    }

    return category;
}

+(NSString*)pair:(NSString*)type value:(NSString*)value
{
    return [NSString stringWithFormat: @"%@:%@", type, value];
}

@end
