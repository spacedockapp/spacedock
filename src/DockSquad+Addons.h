#import "DockSquad.h"

@class DockAdmiral;
@class DockEquippedShip;
@class DockEquippedUpgrade;
@class DockFlagship;
@class DockFleetCaptain;
@class DockUpgrade;
@class DockCaptain;
@class DockShip;

@interface DockSquad (Addons)
@property (nonatomic, readonly) int cost;
+(DockSquad*)squadForUUID:(NSString*)uuid context:(NSManagedObjectContext*)context;
+(void)assignUUIDs:(NSManagedObjectContext*)context;
+(void)deleteAllSquads:(NSManagedObjectContext*)context;
+(DockSquad*)squad:(NSManagedObjectContext*)context;
+(NSArray*)allSquads:(NSManagedObjectContext*)context;
+(NSSet*)allNames:(NSManagedObjectContext*)context;
+(DockSquad*)import:(NSString*)name data:(NSString*)datFormatString context:(NSManagedObjectContext*)context;
+(void)import:(NSString*)datFormatString context:(NSManagedObjectContext*)context;
+(DockSquad*)importOneSquad:(NSDictionary*)squadData context:(NSManagedObjectContext*)context;
+(DockSquad*)importOneSquad:(NSDictionary*)squadData replaceUUID:(BOOL)replaceUUID context:(NSManagedObjectContext*)context;
+(DockSquad*)importOneSquadFromString:(NSString*)squadData context:(NSManagedObjectContext*)context;
+(NSError*)saveSquadsToDisk:(NSString*)targetPath context:(NSManagedObjectContext*)context;
+(NSData *)allSquadsAsJSON:(NSManagedObjectContext *)context error:(NSError **)error;
+(void)startImport;
+(void)doneImport;
-(void)importIntoSquad:(NSDictionary*)squadData replaceUUID:(BOOL)replaceUUID;
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
-(BOOL)canAddAdmiral:(DockAdmiral*)admiral toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(DockEquippedUpgrade*)addAdmiral:(DockAdmiral*)admiral toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(DockEquippedUpgrade*)addFleetCaptain:(DockFleetCaptain*)fleetCaptain toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(BOOL)canAddFleetCaptain:(DockFleetCaptain*)fleetCaptain toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(DockEquippedUpgrade*)equippedFleetCaptain;
-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(DockEquippedShip*)addSideboard;
-(DockFlagship*)flagship;
-(BOOL)flagshipIsNotAssigned;
-(void)purgeUpgrade:(DockUpgrade*)upgrade;
@end
