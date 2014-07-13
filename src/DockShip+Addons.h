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
-(BOOL)isBreen;
-(BOOL)isJemhadar;
-(BOOL)isKeldon;
-(BOOL)isRomulanScienceVessel;
-(BOOL)isDefiant;
-(BOOL)isUnique;
-(BOOL)isFederation;
-(BOOL)isBajoran;
-(BOOL)isFighterSquadron;
-(BOOL)isSpecies8472;
-(BOOL)isKazon;
-(BOOL)isBorg;
-(BOOL)isTholian;
-(BOOL)isVoyager;
-(BOOL)isVulcan;
-(BOOL)isBajoranInterceptor;
-(BOOL)isBattleshipOrCruiser;
-(DockResource*)associatedResource;
-(int)techCount;
-(int)weaponCount;
-(int)crewCount;
-(int)captainCount;
-(int)admiralCount;
-(int)borgCount;
-(NSArray*)actionStrings;
-(void)updateShipClass:(NSString*)newShipClass;
-(NSString*)descriptiveTitle;
@end
