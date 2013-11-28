#import "DockResource.h"

@interface DockResource (Addons)
+(DockResource*)resourceForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
+(DockResource*)sideboardResource:(NSManagedObjectContext*)context;
-(BOOL)isSideboard;
@end
