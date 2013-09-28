#import "DockEquippedShip.h"

@class DockUpgrade;
@class DockCaptain;

@interface DockEquippedShip (Addons)
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) int cost;
@property (nonatomic, readonly) DockCaptain* captain;
-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade;
-(void)removeUpgrade:(DockUpgrade*)upgrade;
@end
