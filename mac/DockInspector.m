#import "DockInspector.h"

#import "DockAppDelegate.h"
#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockMoveGrid.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockResource+Addons.h"
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

-(void)updateForShip
{
    _moveGrid.ship = self.currentShip;
}

-(void)updateSet:(DockSetItem*)item
{
    DockSet* set  = item.sets.anyObject;
    
    self.currentSetName = set.productName;
}

-(void)clearSet
{
    self.currentSetName = @"";
}

-(void)updateUpgrade:(DockUpgrade*)upgrade
{
    if (upgrade != nil && upgrade != _currentUpgrade) {
        self.currentUpgrade = upgrade;
        [self updateSet: upgrade];
    }
}

-(void)updateCaptain:(DockCaptain*)captain
{
    if (captain != nil && captain != _currentCaptain) {
        self.currentCaptain = captain;
        [self updateSet: captain];
    }
}

-(void)updateShip:(DockShip*)ship
{
    if (ship != nil && ship != _currentShip) {
        self.currentShip = ship;
        [self updateForShip];
        [self updateSet: ship];
    }
}

-(void)updateInspectorTabForItem:(id)selectedItem changeTab:(BOOL)changeTab
{
    if ([selectedItem isMemberOfClass: [DockEquippedShip class]]) {
        [self updateShip: [selectedItem ship]];
        [_tabView selectTabViewItemWithIdentifier: @"ship"];
    } else if ([selectedItem isMemberOfClass: [DockEquippedUpgrade class]]) {
        DockUpgrade* upgrade = [selectedItem upgrade];

        if ([upgrade isCaptain]) {
            [self updateCaptain: (DockCaptain*)upgrade];

            if (changeTab) {
                [_tabView selectTabViewItemWithIdentifier: @"captain"];
            }
        } else if ([upgrade isPlaceholder]) {
            if (changeTab) {
                [_tabView selectTabViewItemWithIdentifier: @"blank"];
            }
            [self clearSet];
        } else {
            [self updateUpgrade: upgrade];

            if (changeTab) {
                [_tabView selectTabViewItemWithIdentifier: @"upgrade"];
            }
        }
    }
}

-(void)updateInspectorTabForItem:(id)selectedItem
{
    [self updateInspectorTabForItem: selectedItem changeTab: NO];
}

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context
{
    @try {
        id responder = [_mainWindow firstResponder];
        NSString* ident = [responder identifier];
        
        if (object == _mainWindow) {
            if ([ident isEqualToString: @"captainsTable"]) {
                [self updateCaptain: extractSelectedItem(_captains)];
                [_tabView selectTabViewItemWithIdentifier: @"captain"];
            } else if ([ident isEqualToString: @"upgradeTable"]) {
                [self updateUpgrade: extractSelectedItem(_upgrades)];
                [_tabView selectTabViewItemWithIdentifier: @"upgrade"];
            } else if ([ident isEqualToString: @"shipsTable"]) {
                [self updateShip: extractSelectedItem(_ships)];
                [_tabView selectTabViewItemWithIdentifier: @"ship"];
            } else if ([ident isEqualToString: @"resourcesTable"]) {
                self.currentResource = extractSelectedItem(_resources);
                [_tabView selectTabViewItemWithIdentifier: @"resource"];
                [self updateSet: self.currentResource];
            } else if ([ident isEqualToString: @"squadsDetailOutline"]) {
                id selectedItem = extractSelectedItem(_squadDetail);
                [self updateInspectorTabForItem: selectedItem];
                [self updateSet: selectedItem];
            } else {
                [_tabView selectTabViewItemWithIdentifier: @"blank"];
                [self clearSet];
            }
        } else if (object == _squadDetail) {
            if ([ident isEqualToString: @"squadsDetailOutline"]) {
                id selectedItem = extractSelectedItem(_squadDetail);
                [self updateInspectorTabForItem: selectedItem changeTab: YES];
            }
        } else if (object == _captains) {
            [self updateCaptain: extractSelectedItem(_captains)];
        } else if (object == _ships) {
            [self updateShip: extractSelectedItem(_ships)];
        } else if (object == _upgrades) {
            [self updateUpgrade: extractSelectedItem(_upgrades)];
        } else if (object == _resources) {
            self.currentResource = extractSelectedItem(_resources);
            [self updateSet: self.currentResource];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.shipDetailTab = @"forShip";
    [_inspector setFloatingPanel: YES];
    [_mainWindow addObserver: self forKeyPath: @"firstResponder" options: 0 context: 0];
    [_captains addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_ships addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_upgrades addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_resources addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_squadDetail addObserver: self forKeyPath: @"selectionIndexPath" options: 0 context: 0];
}

-(void)show
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: YES forKey: kInspectorVisible];
    [_inspector orderFront: self];
}

-(BOOL)windowShouldClose:(id)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: NO forKey: kInspectorVisible];
    return YES;
}

-(IBAction)toggleShipClass:(id)sender
{
    if ([self.shipDetailTab isEqualToString: @"forClass"]) {
        self.shipDetailTab = @"forShip";
    } else {
        self.shipDetailTab = @"forClass";
    }
}

@end
