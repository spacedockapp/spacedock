#import "DockTagHandler.h"

@interface DockShipClassTagHandler : DockTagHandler
-(id)initWithShipClass:(NSString*)shipClass;
-(id)initWithShipClasses:(NSArray*)shipClasses;
-(id)initWithShipClassSet:(NSSet*)shipClassSet;
@end
