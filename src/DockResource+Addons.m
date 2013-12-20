#import "DockResource+Addons.h"

@implementation DockResource (Addons)

static NSString* kSideboardExternalId = @"4003";
static NSString* kFlagshipExternalId = @"4004";

+(DockResource*)resourceForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Resource" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"externalId == %@", externalId];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

+(DockResource*)sideboardResource:(NSManagedObjectContext*)context
{
    return [DockResource resourceForId: kSideboardExternalId context: context];
}

+(DockResource*)flagshipResource:(NSManagedObjectContext*)context
{
    return [DockResource resourceForId: kFlagshipExternalId context: context];
}

-(NSString*)plainDescription
{
    return self.title;
}

-(BOOL)isSideboard
{
    return [self.externalId isEqualToString: kSideboardExternalId];
}

-(BOOL)isFlagship
{
    return [self.externalId isEqualToString: kFlagshipExternalId];
}

@end
