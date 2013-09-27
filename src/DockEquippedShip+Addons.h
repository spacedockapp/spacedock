#import "DockEquippedShip.h"

@class DockUpgrade;

@interface DockEquippedShip (Addons)
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) int cost;
-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade;
-(void)removeUpgrade:(DockUpgrade*)upgrade;
@end
