#import "DockEquippedShip.h"

extern NSString* kCurrentTargetShipChanged;

@interface DockEquippedShip (MacAddons)
+(DockEquippedShip*)currentTargetShip;
+(void)setCurrentTargetShip:(DockEquippedShip*)targetShip;
+(void)clearCurrentTargetShip;
@end
