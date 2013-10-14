#import "DockEquippedShip.h"

@class DockUpgrade;
@class DockCaptain;

@interface DockEquippedShip (Addons)
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) int cost;
@property (nonatomic, readonly) DockCaptain* captain;
+(DockEquippedShip*)equippedShipWithShip:(DockShip*)ship;
-(DockEquippedUpgrade*)equippedCaptain;
-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade;
-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade;
-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade maybeReplace:(DockEquippedUpgrade*)maybeReplace;
-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade maybeReplace:(DockEquippedUpgrade*)maybeReplace establishPlaceholders:(BOOL)establish;
-(DockEquippedUpgrade*)firstUpgrade:(NSString*)upType;
-(DockEquippedUpgrade*)mostExpensiveUpgradeOfFaction:(NSString*)faction;
-(void)removeUpgrade:(DockEquippedUpgrade*)upgrade;
-(void)removeUpgrade:(DockEquippedUpgrade*)upgrade establishPlaceholders:(BOOL)doEstablish;
-(void)removeCaptain;
-(int)talentCount;
-(NSArray*)sortedUpgrades;
-(NSString*)plainDescription;
-(DockEquippedUpgrade*)containsUpgrade:(DockUpgrade*)theUpgrade;
-(void)changeShip:(DockShip*)newShip;
@end
