#import "DockShip.h"

@class DockManeuver;
@class DockFlagship;

@interface DockShip (Addons)
-(NSAttributedString*)styledDescription;
+(DockShip*)shipForId:(NSString*)externalId context:(NSManagedObjectContext*)context;
-(DockShip*)counterpart;
-(NSString*)plainDescription;
-(NSString*)factionCode;
-(BOOL)isBreen;
-(BOOL)isJemhadar;
-(BOOL)isKeldon;
-(BOOL)isRomulanScienceVessel;
-(BOOL)isDefiant;
-(BOOL)isUnique;
-(BOOL)isFederation;
-(BOOL)isBajoran;
-(int)techCount;
-(int)weaponCount;
-(int)crewCount;
-(NSArray*)actionStrings;
-(void)updateShipClass:(NSString*)newShipClass;
-(NSString*)descriptiveTitle;
@end
