#import "DockResource.h"

extern NSString* kOfficerCardsExternalId;

@class DockShip;

@interface DockResource (Addons)
+(DockResource*)resourceForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
+(DockResource*)sideboardResource:(NSManagedObjectContext*)context;
+(DockResource*)flagshipResource:(NSManagedObjectContext*)context;
-(BOOL)isSideboard;
-(BOOL)isFlagship;
-(BOOL)isFighterSquadron;
-(BOOL)isFleetCaptain;
-(BOOL)isOfficerCards;
-(BOOL)isEquippedIntoSquad;
-(BOOL)isEquippedIntoSquad:(DockSquad*)thisSquad;
-(DockShip*)associatedShip;
-(NSString*)asPlainTextFormat;
-(NSNumber*)costForSquad:(DockSquad*)squad;
@end
