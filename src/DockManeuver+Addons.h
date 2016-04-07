#import "DockManeuver.h"

@interface DockManeuver (Addons)
-(NSString*)asString;
-(NSComparisonResult)compareTo:(DockManeuver*)other;
-(BOOL)isSpin;
-(BOOL)isFlank;
-(BOOL)isComeAbout;
@end
