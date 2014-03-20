#import "DockSquad.h"

@class DockEquippedShip;
@class DockEquippedUpgrade;
@class DockFlagship;
@class DockUpgrade;
@class DockCaptain;
@class DockShip;

@interface DockSquad (Addons)
@property (nonatomic, readonly) int cost;
+(void)assignUUIDs:(NSManagedObjectContext*)context;
+(NSArray*)allSquads:(NSManagedObjectContext*)context;
+(NSSet*)allNames:(NSManagedObjectContext*)context;
+(DockSquad*)import:(NSString*)name data:(NSString*)datFormatString context:(NSManagedObjectContext*)context;
+(void)import:(NSString*)datFormatString context:(NSManagedObjectContext*)context;
+(DockSquad*)importOneSquad:(NSDictionary*)squadData context:(NSManagedObjectContext*)context;
-(void)checkAndUpdateFileAtPath:(NSString*)path;
-(void)addEquippedShip:(DockEquippedShip*)ship;
-(void)removeEquippedShip:(DockEquippedShip*)ship;
-(void)squadCompositionChanged;
-(void)updateModificationDate;
-(NSString*)shipsDescription;
-(NSString*)asTextFormat;
-(NSString*)asPlainTextFormat;
-(NSString*)asDataFormat;
-(NSDictionary*)asJSON;
-(NSData*)asJSONData;
-(DockEquippedShip*)containsShip:(DockShip*)theShip;
-(DockEquippedUpgrade*)containsUpgrade:(DockUpgrade*)theUpgrade;
-(DockEquippedUpgrade*)containsUpgradeWithName:(NSString*)theName;
-(DockSquad*)duplicate;
-(BOOL)canAddCaptain:(DockCaptain*)captain toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(DockEquippedUpgrade*)addCaptain:(DockCaptain*)captain toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(DockEquippedShip*)addSideboard;
-(DockFlagship*)flagship;
-(BOOL)flagshipIsNotAssigned;
-(void)purgeUpgrade:(DockUpgrade*)upgrade;
@end
