#import "DockEquippedShip.h"

@class DockUpgrade;
@class DockCaptain;

@interface DockEquippedShip (Addons)
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) int cost;
@property (nonatomic, readonly) DockCaptain* captain;
+(DockEquippedShip*)equippedShipWithShip:(DockShip*)ship;
+(DockEquippedShip*)import:(NSDictionary*)esDict context:(NSManagedObjectContext *)context;
-(void)importUpgrades:(NSDictionary*)esDict;
-(DockEquippedShip*)duplicate;
-(DockEquippedUpgrade*)equippedCaptain;
-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade;
-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade;
-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade maybeReplace:(DockEquippedUpgrade*)maybeReplace;
-(DockEquippedUpgrade*)addUpgrade:(DockUpgrade*)upgrade maybeReplace:(DockEquippedUpgrade*)maybeReplace establishPlaceholders:(BOOL)establish;
-(DockEquippedUpgrade*)firstUpgrade:(NSString*)upType;
-(DockEquippedUpgrade*)mostExpensiveUpgradeOfFaction:(NSString*)faction;
-(NSArray*)allUpgradesOfFaction:(NSString*)faction;
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
-(NSArray*)sortedUpgradesWithFlagship;
-(NSString*)plainDescription;
-(NSString*)descriptiveTitle;
-(NSString*)upgradesDescription;
-(NSString*)factionCode;
-(NSDictionary*)asJSON;
-(DockEquippedUpgrade*)containsUpgrade:(DockUpgrade*)theUpgrade;
-(DockEquippedUpgrade*)containsUpgradeWithName:(NSString*)theName;
-(void)changeShip:(DockShip*)newShip;
-(NSDictionary*)explainCantAddUpgrade:(DockUpgrade*)upgrade;
-(void)establishPlaceholders;
-(NSDictionary*)becomeFlagship:(DockFlagship*)flagship;
-(void)removeFlagship;
-(void)purgeUpgrade:(DockUpgrade*)upgrade;
@end
