#import <Foundation/Foundation.h>

@class DockCaptain;
@class DockUpgrade;
@class DockFlagship;
@class DockResource;
@class DockShip;
@class DockMoveGrid;
@class DockReference;

@interface DockInspector : NSObject
@property (assign) IBOutlet NSPanel* inspector;
@property (assign) IBOutlet NSWindow* mainWindow;
@property (assign) IBOutlet NSTabView* tabView;
@property (assign) IBOutlet NSArrayController* captains;
@property (assign) IBOutlet NSArrayController* upgrades;
@property (assign) IBOutlet NSArrayController* ships;
@property (assign) IBOutlet NSArrayController* resources;
@property (assign) IBOutlet NSArrayController* flagships;
@property (assign) IBOutlet NSArrayController* reference;
@property (assign) IBOutlet NSTreeController* squadDetail;
@property (assign) IBOutlet DockMoveGrid* moveGrid;
@property (strong, nonatomic) NSString* targetKind;
@property (strong, nonatomic) DockCaptain* currentCaptain;
@property (strong, nonatomic) DockUpgrade* currentUpgrade;
@property (strong, nonatomic) DockShip* currentShip;
@property (strong, nonatomic) DockResource* currentResource;
@property (strong, nonatomic) DockFlagship* currentFlagship;
@property (strong, nonatomic) DockReference* currentReference;
@property (strong, nonatomic) NSString* shipDetailTab;
@property (strong, nonatomic) NSString* currentSetName;

-(void)show;
@end
