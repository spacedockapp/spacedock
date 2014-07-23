#import <Foundation/Foundation.h>

@class DockEquippedShip;
@class DockEquippedUpgrade;
@class DockSetItem;

@interface DockSquadDetailController : NSResponder
-(DockEquippedShip*)selectedEquippedShip;
-(DockEquippedUpgrade*)selectedEquippedUpgrade;
-(void)selectUpgrade:(DockEquippedUpgrade*)theUpgrade;
-(void)selectEquippedShip:(DockEquippedShip*)theShip;
-(DockSetItem*)selectedItem;
-(BOOL)isFirstResponder;
-(BOOL)hasSelection;
-(IBAction)deleteSelected:(id)sender;
@end
