#import "DockShipClassDetails.h"

@interface DockShipClassDetails (Addons)
+(DockShipClassDetails*)find:(NSString*)shipClass context:(NSManagedObjectContext*)context;
-(void)updateManeuvers:(NSArray*)m;
-(DockManeuver*)getDockManeuver:(int)speed kind:(NSString*)kind;
-(NSString*)movesSummary;
-(NSSet*)speeds;
@end
