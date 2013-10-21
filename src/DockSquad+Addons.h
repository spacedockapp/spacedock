#import "DockSquad.h"

@class DockEquippedShip;

@interface DockSquad (Addons)
@property (nonatomic, readonly) int cost;
+(NSArray*)allSquads:(NSManagedObjectContext*)context;
+(NSSet*)allNames:(NSManagedObjectContext*)context;
+(DockSquad*)import:(NSString*)name data:(NSString*)datFormatString context:(NSManagedObjectContext*)context;
-(void)addEquippedShip:(DockEquippedShip*)ship;
-(void)removeEquippedShip:(DockEquippedShip*)ship;
-(void)squadCompositionChanged;
-(NSString*)asTextFormat;
-(NSString*)asDataFormat;
-(DockEquippedShip*)containsShip:(DockShip*)theShip;
-(DockEquippedUpgrade*)containsUpgrade:(DockUpgrade*)theUpgrade;
-(DockEquippedUpgrade*)containsUpgradeWithName:(NSString*)theName;
-(DockSquad*)duplicate;
@end
