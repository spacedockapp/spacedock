#import "DockUpgrade.h"

#import "DockFactioned.h"

@class DockEquippedShip;

@interface DockUpgrade (Addons) <DockFactioned>
+(NSSet*)allFactions:(NSManagedObjectContext*)context;
+(DockUpgrade*)placeholder:(NSString*)upType inContext:(NSManagedObjectContext*)context;
+(DockUpgrade*)upgradeForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
+(NSArray*)findUpgrades:(NSString*)title context:(NSManagedObjectContext*)context;
-(BOOL)isTalent;
-(BOOL)isCrew;
-(BOOL)isWeapon;
-(BOOL)isBorg;
-(BOOL)isCaptain;
-(BOOL)isAdmiral;
-(BOOL)isFleetCaptain;
-(BOOL)isOfficer;
-(BOOL)isPlaceholder;
-(BOOL)isUnique;
-(BOOL)isDominion;
-(BOOL)isKlingon;
-(BOOL)isBajoran;
-(BOOL)isFederation;
-(BOOL)isVulcan;
-(BOOL)isFactionBorg;
-(BOOL)isRestrictedOnlyByFaction;
-(NSComparisonResult)compareTo:(DockUpgrade*)other;
-(int)limitForShip:(DockEquippedShip*)targetShip;
-(int)additionalWeaponSlots;
-(int)additionalTechSlots;
-(int)additionalCrewSlots;
-(int)additionalHull;
-(int)additionalTalentSlots;
-(int)additionalAttack;
-(NSString*)targetShipClass;
-(NSString*)upSortType;
-(NSString*)typeCode;
-(NSString*)plainDescription;
-(NSString*)disambiguatedTitle;
-(int)costForShip:(DockEquippedShip*)equippedShip;
-(int)costForShip:(DockEquippedShip*)equippedShip equippedUpgade:(DockEquippedUpgrade*)equippedUpgrade;
-(NSString*)upType;
-(void)setUpType:(NSString*)upType;
@end
