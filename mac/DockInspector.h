#import <Foundation/Foundation.h>

@class DockCaptain;
@class DockUpgrade;
@class DockFlagship;
@class DockResource;
@class DockShip;
@class DockMoveGrid;

@interface DockInspector : NSObject
@property (assign) IBOutlet NSPanel* inspector;
@property (assign) IBOutlet NSWindow* mainWindow;
@property (assign) IBOutlet NSTabView* tabView;
@property (assign) IBOutlet NSArrayController* captains;
@property (assign) IBOutlet NSArrayController* upgrades;
@property (assign) IBOutlet NSArrayController* ships;
@property (assign) IBOutlet NSArrayController* resources;
@property (assign) IBOutlet NSArrayController* flagships;
@property (assign) IBOutlet NSTreeController* squadDetail;
@property (assign) IBOutlet DockMoveGrid* moveGrid;
@property (strong, nonatomic) NSString* targetKind;
@property (weak, nonatomic) DockCaptain* currentCaptain;
@property (weak, nonatomic) DockUpgrade* currentUpgrade;
@property (weak, nonatomic) DockShip* currentShip;
@property (weak, nonatomic) DockResource* currentResource;
@property (weak, nonatomic) DockFlagship* currentFlagship;
@property (strong, nonatomic) NSString* shipDetailTab;
@property (strong, nonatomic) NSString* currentSetName;

-(void)show;
@end
