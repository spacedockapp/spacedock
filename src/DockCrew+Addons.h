#import "DockCrew.h"

@interface DockCrew (Addons)
+(DockCrew*)crewForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
@end
