#import <Foundation/Foundation.h>

#import "DockTabControllerConstants.h"

@class DockAppDelegate;
@class DockEquippedShip;
@class DockSetItem;
@class DockSquad;

@interface DockTabController : NSObject
@property (assign) IBOutlet NSTabViewItem* targetTab;
@property (assign) IBOutlet NSArrayController* targetController;
@property (assign) IBOutlet DockAppDelegate* appDelegate;
@property (nonatomic, readonly) NSWindow* window;
@property (nonatomic, readonly) BOOL dependsOnFaction;
@property (nonatomic, copy) NSString* originalTitle;
@property (assign, nonatomic) NSInteger searchResultsCount;

// all tab controllers
+(NSArray*)allTabControllers;
+(DockTabController*)tabControllerForIdentifier:(NSString*)identifier;

// observing
-(void)startObserving;

// add to ship
-(void)addSelectedToSquad:(DockSquad*)selectedSquad ship:(DockEquippedShip*)selectedShip selectedItem:(id)selectedItem;
-(DockEquippedShip*)findEligibleShipForItem:(DockSetItem*)item inSquad:(DockSquad*)squad;
-(void)explainCantUniqueUpgrade:(NSError*)error;

// predicates
-(void)addAdditionalPredicatesForFaction:(NSString*)factionName formatParts:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments;
-(void)updatePredicates;

// selection
-(id)selectedItemIfVisible;

// showing
+(void)makeOneControllerShowItem:(id)item;
+(DockTabController*)tabControlerForItem:(id)item;
-(void)showItem:(id)item;
-(void)resetFiltersForItem:(id)item;

@end
