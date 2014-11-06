#import <Foundation/Foundation.h>
#import "DockShip+Addons.h"
#import "DockUpgrade+Addons.h"

@interface DockDataLoader : NSObject
-(id)initWithContext:(NSManagedObjectContext*)context;
-(NSSet*)validateSpecials;
-(BOOL)loadData:(NSError**)error;
-(void)cleanupDatabase;
-(void)mergeGenericShip:(DockShip*)fromShip intoShip:(DockShip*)intoShip;
-(void)mergeGenericUpgrade:(DockUpgrade*)fromUpgrade intoUpgrade:(DockUpgrade*)intoUpgrade;
@end
