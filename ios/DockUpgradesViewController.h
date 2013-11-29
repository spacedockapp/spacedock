#import "DockTableViewController.h"

@class DockUpgrade;
@class DockSquad;
@class DockEquippedShip;
@class DockUpgradeDetailViewController;

typedef void (^ DockUpgradePicked)(DockUpgrade*);

@interface DockUpgradesViewController : DockTableViewController
@property (strong, nonatomic) IBOutlet DockUpgradeDetailViewController* detailViewController;
@property (strong, nonatomic) NSString* upType;
@property (nonatomic, strong) DockUpgradePicked onUpgradePicked;
@property (nonatomic, weak) DockSquad* targetSquad;
@property (nonatomic, weak) DockEquippedShip* targetShip;
@property (nonatomic, weak) DockUpgrade* targetUpgrade;
-(void)targetSquad:(DockSquad*)squad onPicked:(DockUpgradePicked)onPicked;
-(void)targetSquad:(DockSquad*)squad ship:(DockEquippedShip*)ship onPicked:(DockUpgradePicked)onPicked;
-(void)targetSquad:(DockSquad*)squad ship:(DockEquippedShip*)ship upgrade:(DockUpgrade*)upgrade onPicked:(DockUpgradePicked)onPicked;
-(void)clearTarget;
@end
