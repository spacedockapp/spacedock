#import "DockInspector.h"

#import "DockEquippedUpgrade+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockShip+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockInspector

static id extractSelectedItem(id controller)
{
    NSArray* selectedItems = [controller selectedObjects];
    if (selectedItems.count > 0) {
        return selectedItems[0];
    }
    return nil;
}

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context
{
    if (object == _mainWindow) {
        id responder = [_mainWindow firstResponder];
        NSString* ident = [responder identifier];
        if ([ident isEqualToString: @"captainsTable"]) {
            [_tabView selectTabViewItemWithIdentifier: @"captain"];
        } else if ([ident isEqualToString: @"upgradeTable"]) {
            [_tabView selectTabViewItemWithIdentifier: @"upgrade"];
        } else {
            [_tabView selectTabViewItemWithIdentifier: @"ship"];
        }
    } else if (object == _squadDetail) {
        id selectedItem = extractSelectedItem(_squadDetail);
        if ([selectedItem isMemberOfClass: [DockEquippedShip class]]) {
            [_tabView selectTabViewItemWithIdentifier: @"ship"];
        } else if ([selectedItem isMemberOfClass: [DockEquippedUpgrade class]]) {
            DockUpgrade* upgrade = [selectedItem upgrade];
            if ([upgrade isCaptain]) {
                [_tabView selectTabViewItemWithIdentifier: @"captain"];
                self.currentCaptain = (DockCaptain*)upgrade;
            } else {
                [_tabView selectTabViewItemWithIdentifier: @"upgrade"];
                self.currentUpgrade = upgrade;
            }
        } else {
            NSLog(@"got detail %@", selectedItem);
        }
    } else if (object == _captains) {
        self.currentCaptain = extractSelectedItem(_captains);
    } else if (object == _upgrades) {
        self.currentUpgrade = extractSelectedItem(_upgrades);
    }
}

-(void)selectionChanged:(NSNotification*)notification
{
    id object = [notification object];
    NSString* notObj = [object identifier];
    NSLog(@"%@ is up", notObj);
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [_inspector setFloatingPanel: YES];
    [_mainWindow addObserver: self forKeyPath: @"firstResponder" options: 0 context: 0];
    [_captains addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_upgrades addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_squadDetail addObserver: self forKeyPath: @"selectionIndexPath" options: 0 context: 0];
}

@end
