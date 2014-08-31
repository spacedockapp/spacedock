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

+(DockTag*)findOrCreateTag:(NSString*)tagValue context:(NSManagedObjectContext*)context;
{
    DockTag* tag = nil;
    NSEntityDescription* entity = [NSEntityDescription entityForName: kDockTagEntityName inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"value = %@", tagValue];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count == 0) {
        tag = [[DockTag alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
        tag.value = tagValue;
    } else {
        assert(existingItems.count == 1);
        tag = existingItems[0];
    }

    return tag;
}

+(DockTag*)findOrCreateCategoryTag:(NSString*)type value:(NSString*)value context:(NSManagedObjectContext*)context
{
    NSString* categoryTagValue = [DockTag categoryTag: type value: value];
    return [DockTag findOrCreateTag: categoryTagValue context: context];
}

@end
