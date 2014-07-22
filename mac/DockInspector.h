#import <Foundation/Foundation.h>

@class DockAdmiral;
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
@property (assign) IBOutlet NSTreeController* squadDetail;
@property (assign) IBOutlet DockMoveGrid* moveGrid;
@property (strong, nonatomic) NSString* targetKind;
@property (strong, nonatomic) NSDictionary* currentAdmiral;
@property (strong, nonatomic) NSDictionary* currentCaptain;
@property (strong, nonatomic) NSDictionary* currentUpgrade;
@property (strong, nonatomic) NSDictionary* currentShip;
@property (strong, nonatomic) NSDictionary* currentResource;
@property (strong, nonatomic) NSDictionary* currentFlagship;
@property (strong, nonatomic) NSDictionary* currentReference;
@property (strong, nonatomic) NSString* shipDetailTab;
@property (strong, nonatomic) NSString* currentSetName;

-(void)show;
@end
