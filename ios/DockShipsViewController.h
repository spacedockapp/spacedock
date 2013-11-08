#import "DockTableViewController.h"

@class DockSquad;
@class DockShip;

typedef void (^DockShipPicked)(DockShip*);

@interface DockShipsViewController : DockTableViewController
-(void)targetSquad:(DockSquad*)squad onPicked:(DockShipPicked)onPicked;
-(void)targetSquad:(DockSquad*)squad ship:(DockShip*)ship onPicked:(DockShipPicked)onPicked;
-(void)clearTarget;
@end
