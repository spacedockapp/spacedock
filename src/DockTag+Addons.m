#import "DockTag+Addons.h"

NSString* kDockTagEntityName = @"Tag";

@implementation DockTag (Addons)

+(NSString*)categoryTag:(NSString*)type value:(NSString*)value
{
    return [NSString stringWithFormat: @"%@\v%@", type, value];
}

+(NSString*)categoryValue:(NSString*)categoryTag;
{
    NSArray* parts = [categoryTag componentsSeparatedByString:@"\v"];
    return [parts lastObject];
}

+(DockTag*)findOrCreateCategoryTag:(NSString*)type value:(NSString*)value context:(NSManagedObjectContext*)context
{
    DockTag* categoryTag = nil;
    NSEntityDescription* entity = [NSEntityDescription entityForName: kDockTagEntityName inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSString* categoryTagValue = [DockTag categoryTag: type value: value];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"value = %@", categoryTag];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count == 0) {
        categoryTag = [[DockTag alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
        categoryTag.value = categoryTagValue;
    } else {
        assert(existingItems.count == 1);
        categoryTag = existingItems[0];
    }

    return categoryTag;
}

@end
