#import "DockShipClassTagHandler.h"

@interface DockShipClassAdjustmentHandler : DockShipClassTagHandler
-(id)initWithShipClass:(NSString*)shipClass adjustment:(int)adjustment;
-(id)initWithShipClasses:(NSArray*)shipClasses adjustment:(int)adjustment;
-(id)initWithShipClassSet:(NSSet*)shipClassSet adjustment:(int)adjustment;
@end
