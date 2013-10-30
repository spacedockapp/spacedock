#import "DockTableViewController.h"

@class DockSquad;
@class DockShip;

typedef void (^DockShipPicked)(DockShip*);

@protocol DockShipSelectionTarget <NSObject>
@end

@interface DockShipsViewController : DockTableViewController
@property (nonatomic, strong) DockShipPicked onShipPicked;
@property (nonatomic, weak) DockSquad *targetSquad;
-(void)targetSquad:(DockSquad*)squad onPicked:(DockShipPicked)onPicked;
-(void)clearTarget;
@end
