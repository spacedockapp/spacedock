#import "DockTableViewController.h"

@class DockUpgrade;
@class DockSquad;

typedef void (^DockUpgradePicked)(DockUpgrade*);

@interface DockUpgradesViewController : DockTableViewController
@property (strong, nonatomic) NSString* upType;
@property (nonatomic, strong) DockUpgradePicked onUpgradePicked;
@property (nonatomic, weak) DockSquad *targetSquad;
-(void)targetSquad:(DockSquad*)squad onPicked:(DockUpgradePicked)onPicked;
-(void)clearTarget;
@end
