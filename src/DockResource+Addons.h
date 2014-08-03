#import "DockResource.h"

@class DockShip;

@interface DockResource (Addons)
+(DockResource*)resourceForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
+(DockResource*)sideboardResource:(NSManagedObjectContext*)context;
+(DockResource*)flagshipResource:(NSManagedObjectContext*)context;
-(BOOL)isSideboard;
-(BOOL)isFlagship;
-(BOOL)isFighterSquadron;
-(BOOL)isEquippedIntoSquad;
-(BOOL)isEquippedIntoSquad:(DockSquad*)thisSquad;
-(DockShip*)associatedShip;
-(NSString*)asPlainTextFormat;
@end
