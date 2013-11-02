#import "DockTableViewController.h"

@class DockUpgrade;
@class DockSquad;
@class DockEquippedShip;

typedef void (^DockUpgradePicked)(DockUpgrade*);

@interface DockUpgradesViewController : DockTableViewController
@property (strong, nonatomic) NSString* upType;
@property (nonatomic, strong) DockUpgradePicked onUpgradePicked;
@property (nonatomic, weak) DockSquad *targetSquad;
@property (nonatomic, weak) DockEquippedShip *targetShip;
-(void)targetSquad:(DockSquad*)squad onPicked:(DockUpgradePicked)onPicked;
-(void)targetSquad:(DockSquad*)squad ship:(DockEquippedShip*)ship onPicked:(DockUpgradePicked)onPicked;
-(void)clearTarget;
@end
