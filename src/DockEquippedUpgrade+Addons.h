#import "DockEquippedUpgrade.h"

@class DockEquippedShip;

@interface DockEquippedUpgrade (Addons)
@property (nonatomic, readonly) int cost;
@property (nonatomic, readonly) BOOL isPlaceholder;
-(NSComparisonResult)compareTo:(DockEquippedUpgrade*)other;
@end
