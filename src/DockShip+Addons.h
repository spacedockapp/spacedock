#import "DockShip.h"

#import "DockFactioned.h"

@class DockManeuver;
@class DockFlagship;
@class DockResource;

@interface DockShip (Addons)<DockFactioned>
+(NSArray*)allShips:(NSManagedObjectContext*)context;
+(DockShip*)shipForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
-(DockShip*)counterpart;
-(NSString*)plainDescription;
-(BOOL)isDefiant;
-(BOOL)isUnique;
-(BOOL)isFederation;
-(BOOL)isBajoran;
-(BOOL)isFighterSquadron;
-(BOOL)isSpecies8472;
-(BOOL)isKazon;
-(BOOL)isBorg;
-(BOOL)isIndependent;
-(DockResource*)associatedResource;
-(int)techCount;
-(int)weaponCount;
-(int)crewCount;
-(int)captainCount;
-(int)admiralCount;
-(int)fleetCaptainCount;
-(int)borgCount;
-(NSArray*)actionStrings;
-(void)updateShipClass:(NSString*)newShipClass;
-(NSString*)descriptiveTitle;
@end
