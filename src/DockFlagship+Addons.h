#import "DockFlagship.h"

#import "DockFactioned.h"

@class DockShip;

@interface DockFlagship (Addons) <DockFactioned>
+(DockFlagship*)flagshipForId:(NSString*)flagshipId context:(NSManagedObjectContext*)context;
-(int)agilityAdd;
-(int)hullAdd;
-(int)attackAdd;
-(int)shieldAdd;
-(int)crewAdd;
-(int)talentAdd;
-(int)techAdd;
-(int)weaponAdd;
-(NSString*)plainDescription;
-(NSString*)name;
-(BOOL)compatibleWithShip:(DockShip*)targetShip;
@end
