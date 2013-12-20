#import "DockResource.h"

@interface DockResource (Addons)
+(DockResource*)resourceForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
+(DockResource*)sideboardResource:(NSManagedObjectContext*)context;
+(DockResource*)flagshipResource:(NSManagedObjectContext*)context;
-(BOOL)isSideboard;
-(BOOL)isFlagship;
@end
