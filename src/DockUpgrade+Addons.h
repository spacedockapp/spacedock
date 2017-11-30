#import "DockUpgrade.h"

#import "DockFactioned.h"
#import "DockUnique.h"

@class DockEquippedShip;

@interface DockUpgrade (Addons) <DockFactioned,DockUnique>
+(NSSet*)allFactions:(NSManagedObjectContext*)context;
+(DockUpgrade*)placeholder:(NSString*)upType inContext:(NSManagedObjectContext*)context;
+(DockUpgrade*)upgradeForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
+(NSArray*)findUpgrades:(NSString*)title context:(NSManagedObjectContext*)context;
-(BOOL)isTalent;
-(BOOL)isCrew;
-(BOOL)isTech;
-(BOOL)isWeapon;
-(BOOL)isBorg;
-(BOOL)isQMark;
-(BOOL)isCaptain;
-(BOOL)isAdmiral;
-(BOOL)isFleetCaptain;
-(BOOL)isOfficer;
-(BOOL)isSquadron;
-(BOOL)isResourceUpgrade;
-(BOOL)isPlaceholder;
-(BOOL)isUnique;
-(BOOL)isMirrorUniverseUnique;
-(BOOL)isDominion;
-(BOOL)isKazon;
-(BOOL)isKlingon;
-(BOOL)isBajoran;
-(BOOL)isFederation;
-(BOOL)isFerengi;
-(BOOL)isVulcan;
-(BOOL)isFactionBorg;
-(BOOL)isRomulan;
-(BOOL)isQContinuum;
-(BOOL)isXindi;
-(BOOL)isRestrictedOnlyByFaction;
-(NSComparisonResult)compareTo:(DockUpgrade*)other;
-(int)limitForShip:(DockEquippedShip*)targetShip;
-(int)additionalWeaponSlots;
-(int)additionalTechSlots;
-(int)additionalCrewSlots;
-(int)additionalBorgSlots;
-(int)additionalHull;
-(int)additionalTalentSlots;
-(int)additionalAttack;
-(int)additionalShield;
-(NSString*)targetShipClass;
-(NSString*)upSortType;
-(NSString*)typeCode;
-(NSString*)plainDescription;
-(NSString*)titleForPlainTextFormat;
-(NSString*)disambiguatedTitle;
-(int)costForShip:(DockEquippedShip*)equippedShip;
-(int)costForShip:(DockEquippedShip*)equippedShip equippedUpgade:(DockEquippedUpgrade*)equippedUpgrade;
@end
