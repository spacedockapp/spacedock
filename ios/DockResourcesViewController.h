#import "DockTableViewController.h"

@class DockResource;
@class DockSquad;

typedef void (^ DockResourcePicked)(DockResource*);

@interface DockResourcesViewController : DockTableViewController
-(void)targetSquad:(DockSquad*)squad resource:(DockResource*)resource onPicked:(DockResourcePicked)onPicked;
@end
