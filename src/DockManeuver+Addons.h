#import "DockManeuver.h"

@interface DockManeuver (Addons)
-(NSString*)asString;
-(NSComparisonResult)compareTo:(DockManeuver*)other;
@end
