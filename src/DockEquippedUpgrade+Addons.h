#import "DockEquippedUpgrade.h"

@class DockEquippedShip;

@interface DockEquippedUpgrade (Addons)
@property (nonatomic, readonly) int cost;
@property (nonatomic, readonly) int rawCost;
@property (nonatomic, readonly) BOOL isPlaceholder;
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSString* faction;
-(NSComparisonResult)compareTo:(DockEquippedUpgrade*)other;
-(NSString*)typeCode;
-(int)baseCost;
@end
