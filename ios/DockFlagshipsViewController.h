#import "DockTableViewController.h"

@class DockShip;
@class DockSquad;
@class DockFlagship;

typedef void (^ DockFlagshipPicked)(DockFlagship*);

@interface DockFlagshipsViewController : DockTableViewController
-(void)targetSquad:(DockSquad*)squad ship:(DockShip*)ship onPicked:(DockFlagshipPicked)onPicked;
@end
