#import "DockUpgrade.h"

@interface DockUpgrade (Addons)
-(BOOL)isTalent;
-(BOOL)isCrew;
-(BOOL)isWeapon;
-(BOOL)isCaptain;
-(NSComparisonResult)compareTo:(DockUpgrade*)other;
@end
