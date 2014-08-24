#import "DockEquippedUpgrade.h"

@class DockEquippedShip;

@interface DockEquippedUpgrade (Addons)
@property (nonatomic, readonly) int cost;
@property (nonatomic, readonly) int rawCost;
@property (nonatomic, readonly) BOOL isPlaceholder;
@property (nonatomic, readonly) NSString* title;
-(NSComparisonResult)compareTo:(DockEquippedUpgrade*)other;
-(NSString*)typeCode;
-(NSString*)descriptionForBuildSheet;
-(NSString*)asPlainTextFormat;
-(int)baseCost;
-(int)nonOverriddenCost;
-(BOOL)costIsOverridden;
-(void)removeCostOverride;
-(void)overrideWithCost:(int)cost;
-(NSDictionary*)asJSON;
-(int)additionalWeaponSlots;
-(int)additionalTechSlots;
-(int)additionalCrewSlots;
-(int)additionalTalentSlots;
@end
