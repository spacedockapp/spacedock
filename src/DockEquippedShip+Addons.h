#import "DockEquippedShip.h"

@class DockUpgrade;
@class DockCaptain;

@interface DockEquippedShip (Addons)
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) int cost;
@property (nonatomic, readonly) DockCaptain* captain;
+(DockEquippedShip*)equippedShipWithShip:(DockShip*)ship;
-(DockEquippedShip*)duplicate;
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
-(int)upgradeCount;
-(int)techCount;
-(int)weaponCount;
-(int)crewCount;
-(int)baseCost;
-(int)attack;
-(int)agility;
-(int)hull;
-(int)shield;
-(BOOL)isResourceSideboard;
-(NSArray*)sortedUpgrades;
-(NSString*)plainDescription;
-(NSString*)descriptiveTitle;
-(NSString*)upgradesDescription;
-(NSString*)factionCode;
-(DockEquippedUpgrade*)containsUpgrade:(DockUpgrade*)theUpgrade;
-(DockEquippedUpgrade*)containsUpgradeWithName:(NSString*)theName;
-(void)changeShip:(DockShip*)newShip;
-(NSDictionary*)explainCantAddUpgrade:(DockUpgrade*)upgrade;
-(void)establishPlaceholders;
-(void)becomeFlagship:(DockFlagship*)flagship;
-(void)removeFlagship;
@end
