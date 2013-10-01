#import "DockSquad.h"

@class DockEquippedShip;

@interface DockSquad (Addons)
@property (nonatomic, readonly) int cost;
-(void)addEquippedShip:(DockEquippedShip*)ship;
-(void)removeEquippedShip:(DockEquippedShip*)ship;
-(void)squadCompositionChanged;
-(NSString*)asTextFormat;
@end
