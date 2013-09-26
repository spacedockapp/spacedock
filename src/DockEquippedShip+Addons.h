#import "DockEquippedShip.h"

@class DockUpgrade;

@interface DockEquippedShip (Addons)
@property (nonatomic, readonly) NSString* title;
-(void)addUpgrade:(DockUpgrade*)upgrade;
@end
