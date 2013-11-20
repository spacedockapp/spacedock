#import <Foundation/Foundation.h>

@class DockCaptain;
@class DockUpgrade;
@class DockResource;
@class DockShip;

@interface DockInspector : NSObject
@property (assign) IBOutlet NSPanel* inspector;
@property (assign) IBOutlet NSWindow* mainWindow;
@property (assign) IBOutlet NSTabView* tabView;
@property (assign) IBOutlet NSArrayController* captains;
@property (assign) IBOutlet NSArrayController* upgrades;
@property (assign) IBOutlet NSArrayController* ships;
@property (assign) IBOutlet NSArrayController* resources;
@property (assign) IBOutlet NSTreeController* squadDetail;
@property (strong, nonatomic) NSString* targetKind;
@property (weak, nonatomic) DockCaptain* currentCaptain;
@property (weak, nonatomic) DockUpgrade* currentUpgrade;
@property (weak, nonatomic) DockShip* currentShip;
@property (weak, nonatomic) DockResource* currentResource;
-(void)show;
@end
