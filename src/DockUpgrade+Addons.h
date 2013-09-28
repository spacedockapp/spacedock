#import "DockUpgrade.h"

@interface DockUpgrade (Addons)
+(DockUpgrade*)placeholder:(NSString*)upType inContext:(NSManagedObjectContext*)context;
-(BOOL)isTalent;
-(BOOL)isCrew;
-(BOOL)isWeapon;
-(BOOL)isCaptain;
-(NSComparisonResult)compareTo:(DockUpgrade*)other;
@end
