#import "DockShip.h"

@class DockManeuver;
@class DockFlagship;
@class DockResource;

@interface DockShip (Addons)
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
-(DockResource*)associatedResource;
-(int)techCount;
-(int)weaponCount;
-(int)crewCount;
-(int)captainCount;
-(NSArray*)actionStrings;
-(void)updateShipClass:(NSString*)newShipClass;
-(NSString*)descriptiveTitle;
@end
