#import "DockTableViewController.h"

@class DockEquippedUpgrade;
@class DockSquad;
@class DockEquippedShip;
@class DockUpgrade;
@class DockUpgradeDetailViewController;

typedef void (^ DockUpgradePicked)(DockUpgrade*, BOOL override, int overrideCost);

@interface DockUpgradesViewController : DockTableViewController
@property (strong, nonatomic) IBOutlet DockUpgradeDetailViewController* detailViewController;
@property (strong, nonatomic) NSString* upType;
@property (strong, nonatomic) NSString* upgradeTypeName;
@property (nonatomic, strong) DockUpgradePicked onUpgradePicked;
@property (nonatomic, weak) DockSquad* targetSquad;
@property (nonatomic, weak) DockEquippedShip* targetShip;
@property (nonatomic, weak) DockEquippedUpgrade* targetUpgrade;
@property (nonatomic, assign) BOOL showAdmirals;
-(void)targetSquad:(DockSquad*)squad onPicked:(DockUpgradePicked)onPicked;
-(void)targetSquad:(DockSquad*)squad ship:(DockEquippedShip*)ship onPicked:(DockUpgradePicked)onPicked;
-(void)targetSquad:(DockSquad*)squad ship:(DockEquippedShip*)ship upgrade:(DockEquippedUpgrade*)upgrade onPicked:(DockUpgradePicked)onPicked;
-(void)clearTarget;
@end
