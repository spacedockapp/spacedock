#import "DockShipClassDetails.h"

@interface DockShipClassDetails (Addons)
+(DockShipClassDetails*)find:(NSString*)shipClass context:(NSManagedObjectContext*)context;
-(void)updateManeuvers:(NSArray*)m;
@end
