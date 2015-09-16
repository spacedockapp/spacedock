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
-(BOOL)isRemanWarbird;
-(BOOL)isDefiant;
-(BOOL)isUnique;
-(BOOL)isMirrorUniverseUnique;
-(BOOL)isAnyKindOfUnique;
-(BOOL)isFederation;
-(BOOL)isFerengi;
-(BOOL)isBajoran;
-(BOOL)isFighterSquadron;
-(BOOL)isShuttle;
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
-(BOOL)isRomulan;
-(BOOL)isKlingon;
-(BOOL)isBajoranInterceptor;
-(BOOL)isBattleshipOrCruiser;
-(BOOL)isRaven;
-(BOOL)isScoutCube;
-(BOOL)isGalaxyClass;
-(BOOL)isIntrepidClass;
-(BOOL)isSovereignClass;
-(BOOL)isKlingonBirdOfPrey;
-(BOOL)isDominion;
-(BOOL)isXindi;
-(DockResource*)associatedResource;
-(int)techCount;
-(int)weaponCount;
-(int)crewCount;
-(int)captainCount;
-(int)admiralCount;
-(int)fleetCaptainCount;
-(int)borgCount;
-(int)squadronUpgradeCount;
-(NSArray*)actionStrings;
-(void)updateShipClass:(NSString*)newShipClass;
-(void)updateShipClassWithId:(NSString*)newShipClassId;
-(NSString*)descriptiveTitle;
-(NSString*)uniqueAsString;
@end
