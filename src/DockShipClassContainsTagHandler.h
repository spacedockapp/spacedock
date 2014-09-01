#import "DockTagHandler.h"

@interface DockShipClassContainsTagHandler : DockTagHandler
@property (strong,nonatomic) NSSet* shipClassSubstrings;
-(id)initWithShipClassSubstrings:(NSArray*)shipClassSubstrings;
-(BOOL)matchesShip:(DockEquippedShip*)equippedShip;
@end
