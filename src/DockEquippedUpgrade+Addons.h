#import "DockEquippedUpgrade.h"

@class DockEquippedShip;

@interface DockEquippedUpgrade (Addons)
@property (nonatomic, readonly) int cost;
-(NSComparisonResult)compareTo:(DockEquippedUpgrade*)other;
@end
