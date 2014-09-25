#import "DockShip.h"

#import "DockFactioned.h"
#import "DockUnique.h"

@class DockManeuver;
@class DockFlagship;
@class DockResource;

@interface DockShip (Addons)<DockFactioned,DockUnique>
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
-(BOOL)isMirrorUniverseUnique;
-(BOOL)isAnyKindOfUnique;
-(BOOL)isFederation;
-(BOOL)isFerengi;
-(BOOL)isBajoran;
-(BOOL)isFighterSquadron;
-(BOOL)isSpecies8472;
-(BOOL)isKazon;
-(BOOL)isBorg;
-(BOOL)isTholian;
-(BOOL)isVoyager;
-(BOOL)isVulcan;
-(BOOL)isMirrorUniverse;
-(BOOL)isSuurokClass;
-(BOOL)isPredatorClass;
-(BOOL)isIndependent;
-(BOOL)isBajoranInterceptor;
-(BOOL)isBattleshipOrCruiser;
-(BOOL)isRaven;
-(BOOL)isScoutCube;
-(BOOL)isGalaxyClass;
-(BOOL)isIntrepidClass;
-(BOOL)isSovereignClass;
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
-(NSString*)uniqueAsString;
@end
