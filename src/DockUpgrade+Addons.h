#import "DockUpgrade.h"

@class DockEquippedShip;

@interface DockUpgrade (Addons)
+(NSSet*)allFactions:(NSManagedObjectContext*)context;
+(DockUpgrade*)placeholder:(NSString*)upType inContext:(NSManagedObjectContext*)context;
+(DockUpgrade*)upgradeForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
+(NSArray*)findUpgrades:(NSString*)title context:(NSManagedObjectContext*)context;
-(BOOL)isTalent;
-(BOOL)isCrew;
-(BOOL)isWeapon;
-(BOOL)isCaptain;
-(BOOL)isPlaceholder;
-(BOOL)isUnique;
-(BOOL)isDominion;
-(BOOL)isKlingon;
-(NSComparisonResult)compareTo:(DockUpgrade*)other;
-(int)limitForShip:(DockEquippedShip*)targetShip;
-(NSAttributedString*)styledDescription;
-(NSString*)targetShipClass;
-(NSString*)upSortType;
-(NSString*)typeCode;
-(NSString*)plainDescription;
-(NSString*)factionCode;
-(int)costForShip:(DockEquippedShip*)equippedShip;
@end
