#import "DockInspector.h"

#import "DockAppDelegate.h"
#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip+MacAddons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockMoveGrid.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockResource+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockInspector

+(NSSet*)keyPathsForValuesAffectingCurrentSetName
{
    return [NSSet setWithObjects: @"currentCaptain", @"currentUpgrade", @"currentShip", @"currentResource", @"currentFlagship", @"currentReference", nil];
}


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

-(void)updateSet:(id)target
{
    if (target == nil) {
        self.currentSetName = @"";
        return;
    }
    DockSetItem* item = target;
    if (![target isKindOfClass: [DockSetItem class]]) {
        if (![target isKindOfClass: [DockEquippedShip class]]) {
            return;
        }
        DockEquippedShip* equippedShip = (DockEquippedShip*)target;
        item = equippedShip.ship;
    }
    NSSet* sets  = item.sets;
    if (sets != nil) {
        DockSet* set  = item.sets.anyObject;
        self.currentSetName = set.productName;
    }
}

-(void)clearSet
{
    self.currentSetName = @"";
}

-(void)updateUpgrade:(DockUpgrade*)upgrade
{
    if (upgrade != nil && upgrade != _currentUpgrade) {
        self.currentUpgrade = upgrade;
    }
    [self updateSet: upgrade];
}

-(void)updateCaptain:(DockCaptain*)captain
{
    if (captain != nil && captain != _currentCaptain) {
        self.currentCaptain = captain;
    }
    [self updateSet: captain];
}

-(void)updateShip:(DockShip*)ship
{
    if (ship != nil && ship != _currentShip) {
        self.currentShip = ship;
        [self updateForShip];
    }
    [self updateSet: ship];
}

-(void)updateFlagship:(DockFlagship*)flagship
{
    if (flagship == nil) {
        [_tabView selectTabViewItemWithIdentifier: @"blank"];
        [self clearSet];
    } else {
        if (flagship != _currentFlagship) {
            self.currentFlagship = flagship;
        }
        [self updateSet: flagship];
    }
}

-(void)updateReference:(DockReference*)reference
{
    if (reference == nil) {
        [_tabView selectTabViewItemWithIdentifier: @"blank"];
        [self clearSet];
    } else {
        if (reference != _currentReference) {
            self.currentReference = reference;
        }
        [self updateSet: nil];
    }
}

-(void)updateInspectorTabForItem:(id)selectedItem changeTab:(BOOL)changeTab
{
    if ([selectedItem isMemberOfClass: [DockEquippedShip class]]) {
        [DockEquippedShip setCurrentTargetShip: selectedItem];
        [self updateShip: [selectedItem ship]];
        [_tabView selectTabViewItemWithIdentifier: @"ship"];
    } else if ([selectedItem isMemberOfClass: [DockEquippedUpgrade class]]) {
        [DockEquippedShip setCurrentTargetShip: [selectedItem equippedShip]];
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

-(void)selectTabIfBlank:(NSString*)newTab
{
    if ([[[_tabView selectedTabViewItem] identifier] isEqualToString: @"blank"]) {
        [_tabView selectTabViewItemWithIdentifier: newTab];
    }
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
            } else if ([ident isEqualToString: @"flagshipsTable"]) {
                [_tabView selectTabViewItemWithIdentifier: @"flagship"];
                [self updateFlagship: extractSelectedItem(_flagships)];
                [self updateSet: self.currentFlagship];
            } else if ([ident isEqualToString: @"referenceTable"]) {
                [_tabView selectTabViewItemWithIdentifier: @"reference"];
                [self updateReference: extractSelectedItem(_reference)];
                [self clearSet];
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
            [self selectTabIfBlank: @"captain"];
        } else if (object == _ships) {
            [self updateShip: extractSelectedItem(_ships)];
            [self selectTabIfBlank: @"ship"];
        } else if (object == _flagships) {
            [self updateFlagship: extractSelectedItem(_flagships)];
        } else if (object == _upgrades) {
            [self updateUpgrade: extractSelectedItem(_upgrades)];
        } else if (object == _resources) {
            self.currentResource = extractSelectedItem(_resources);
            [self updateSet: self.currentResource];
        } else if (object == _reference) {
            self.currentReference = extractSelectedItem(_reference);
            [self clearSet];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"caught exception %@", exception);
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
    [_flagships addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
    [_reference addObserver: self forKeyPath: @"selectionIndexes" options: 0 context: 0];
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
