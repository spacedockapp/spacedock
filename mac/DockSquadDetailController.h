#import <Foundation/Foundation.h>

@class DockEquippedShip;
@class DockEquippedUpgrade;
@class DockComponent;

extern NSString* kCurrentEquippedUpgrade;

@interface DockSquadDetailController : NSResponder
-(DockEquippedShip*)selectedEquippedShip;
-(DockEquippedUpgrade*)selectedEquippedUpgrade;
-(void)selectUpgrade:(DockEquippedUpgrade*)theUpgrade;
-(void)selectEquippedShip:(DockEquippedShip*)theShip;
-(DockComponent*)selectedItem;
-(BOOL)isFirstResponder;
-(BOOL)hasSelection;
-(IBAction)deleteSelected:(id)sender;
@end
