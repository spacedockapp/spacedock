#import "DockBorg.h"

@interface DockBorg (Addons)
+(DockBorg*)borgForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
@end
