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
@property (strong, nonatomic) NSDictionary* currentEquippedAdmiral;
@property (strong, nonatomic) NSDictionary* currentListAdmiral;
@property (strong, nonatomic, readonly) NSDictionary* currentAdmiral;
@property (strong, nonatomic) NSDictionary* currentListCaptain;
@property (strong, nonatomic) NSDictionary* currentEquippedCaptain;
@property (strong, nonatomic, readonly) NSDictionary* currentCaptain;
@property (strong, nonatomic) NSDictionary* currentListUpgrade;
@property (strong, nonatomic) NSDictionary* currentEquippedUpgrade;
@property (strong, nonatomic, readonly) NSDictionary* currentUpgrade;
@property (strong, nonatomic) NSDictionary* currentListShip;
@property (strong, nonatomic) NSDictionary* currentEquippedShip;
@property (strong, nonatomic, readonly) NSDictionary* currentShip;
@property (strong, nonatomic) NSDictionary* currentResource;
@property (strong, nonatomic) NSDictionary* currentListFlagship;
@property (strong, nonatomic) NSDictionary* currentEquippedFlagship;
@property (strong, nonatomic, readonly) NSDictionary* currentFlagship;
@property (strong, nonatomic) NSDictionary* currentListFleetCaptain;
@property (strong, nonatomic) NSDictionary* currentEquippedFleetCaptain;
@property (strong, nonatomic, readonly) NSDictionary* currentFleetCaptain;
@property (strong, nonatomic) NSDictionary* currentListOfficer;
@property (strong, nonatomic) NSDictionary* currentEquippedOfficer;
@property (strong, nonatomic, readonly) NSDictionary* currentOfficer;
@property (strong, nonatomic) NSDictionary* currentReference;
@property (strong, nonatomic) NSString* shipDetailTab;
@property (strong, nonatomic, readonly) NSString* currentSetName;
@property (strong, nonatomic) NSString* currentListSetName;
@property (strong, nonatomic) NSString* currentEquippedSetName;
@property (strong, nonatomic) NSString* firstResponderIdent;
@property (strong, nonatomic) NSString* currentListTabIdentifier;
@property (strong, nonatomic) NSString* currentEquippedTabIdentifier;
@property (strong, nonatomic, readonly) NSString* currentTabIdentifier;

-(void)show;
@end
