#import "DockTagHandler.h"

@interface DockShipFactionTagHandler : DockTagHandler
@property (strong,nonatomic) NSString* faction;
-(id)initWithFaction:(NSString*)faction;
-(BOOL)matchesShip:(DockEquippedShip*)equippedShip;
@end
