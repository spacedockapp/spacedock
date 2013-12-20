#import "DockFlagship.h"

@class DockShip;

@interface DockFlagship (Addons)
-(int)agilityAdd;
-(int)hullAdd;
-(int)attackAdd;
-(int)shieldAdd;
-(int)crewAdd;
-(int)talentAdd;
-(int)techAdd;
-(int)weaponAdd;
-(NSString*)plainDescription;
-(BOOL)compatibleWithShip:(DockShip*)targetShip;
@end
