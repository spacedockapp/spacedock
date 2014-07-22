#import "DockInspector.h"

#import "DockAdmiralTabController.h"
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
#import "DockTabControllerConstants.h"
#import "DockTabDelegate.h"
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

-(void)updateInspectorTabForItem:(id)selectedItem changeTab:(BOOL)changeTab
{
    if ([selectedItem isMemberOfClass: [DockEquippedShip class]]) {
        [DockEquippedShip setCurrentTargetShip: selectedItem];
        //[self updateShip: [selectedItem ship]];
        [_tabView selectTabViewItemWithIdentifier: @"ship"];
    } else if ([selectedItem isMemberOfClass: [DockEquippedUpgrade class]]) {
        [DockEquippedShip setCurrentTargetShip: [selectedItem equippedShip]];
        DockUpgrade* upgrade = [selectedItem upgrade];

        if ([upgrade isPlaceholder]) {
            if (changeTab) {
                [_tabView selectTabViewItemWithIdentifier: @"blank"];
            }
            [self clearSet];
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

-(NSString*)identToTabIdent:(NSString*)ident
{
    NSDictionary* d = @{
        @"captainsTable" : @"captain",
        @"admiralsTable" : @"admiral",
        @"upgradeTable" : @"upgrade",
        @"shipsTable" : @"ship",
        @"resourcesTable" : @"resource",
        @"flagshipsTable" : @"flagship",
        @"referenceTable" : @"reference"
    };
    return d[ident];
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
            NSString* tabIdent = [self identToTabIdent: ident];
            if (tabIdent == nil) {
                [_tabView selectTabViewItemWithIdentifier: @"blank"];
            } else {
                if ([ident isEqualToString: @"squadsDetailOutline"]) {
                    id selectedItem = extractSelectedItem(_squadDetail);
                    [self updateInspectorTabForItem: selectedItem];
                    [self updateSet: selectedItem];
                } else {
                    [_tabView selectTabViewItemWithIdentifier: tabIdent];
                }
            }
        } else if (object == _squadDetail) {
            if ([ident isEqualToString: @"squadsDetailOutline"]) {
                id selectedItem = extractSelectedItem(_squadDetail);
                [self updateInspectorTabForItem: selectedItem changeTab: YES];
            }
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
    [_squadDetail addObserver: self forKeyPath: @"selectionIndexPath" options: 0 context: 0];

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(admiralChanged:) name: kCurrentAdmiralChanged object: nil];
    [center addObserver: self selector: @selector(captainChanged:) name: kCurrentCaptainChanged object: nil];
    [center addObserver: self selector: @selector(upgradeChanged:) name: kCurrentUpgradeChanged object: nil];
    [center addObserver: self selector: @selector(flagshipChanged:) name: kCurrentFlagshipChanged object: nil];
    [center addObserver: self selector: @selector(shipChanged:) name: kCurrentShipChanged object: nil];
    [center addObserver: self selector: @selector(resourceChanged:) name: kCurrentResourceChanged object: nil];
    [center addObserver: self selector: @selector(referenceChanged:) name: kCurrentReferenceChanged object: nil];
    [center addObserver: self selector: @selector(topTabChanged:) name: kTabSelectionChanged object: nil];
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

#pragma mark - Notifications

static NSDictionary* copyProperties(id target, NSArray* propertyList)
{
    NSMutableDictionary* props = [[NSMutableDictionary alloc] initWithCapacity: propertyList.count];
    for (NSString* name in propertyList) {
        id value = [target valueForKey: name];
        if (value != nil) {
            [props setObject: value forKey: name];
        }
    }
    return [NSDictionary dictionaryWithDictionary: props];
}

-(void)admiralChanged:(NSNotification*)notification
{
    NSArray* displayedAdmiralProperties = @[
        @"styledSkillModifier",
        @"title",
        @"admiralAbility",
        @"admiralCost",
        @"skill"
    ];
    self.currentAdmiral = copyProperties(notification.object, displayedAdmiralProperties);
    [self updateSet: notification.object];
}

-(void)captainChanged:(NSNotification*)notification
{
    NSArray* displayedCaptainProperties = @[
        @"styledSkill",
        @"title",
        @"ability",
        @"cost",
        @"skill"
    ];
    self.currentCaptain = copyProperties(notification.object, displayedCaptainProperties);
    [self updateSet: notification.object];
}

-(void)upgradeChanged:(NSNotification*)notification
{
    NSArray* displayedUgradeProperties = @[
        @"title",
        @"ability",
        @"cost",
        @"optionalRange",
        @"optionalAttack",
    ];
    self.currentUpgrade = copyProperties(notification.object, displayedUgradeProperties);
    [self updateSet: notification.object];
}

-(void)flagshipChanged:(NSNotification*)notification
{
    NSArray* displayedFlagshipProperties = @[
        @"ability",
        @"agility",
        @"attack",
        @"capabilities",
        @"hull",
        @"shield",
        @"title",
    ];
    self.currentFlagship = copyProperties(notification.object, displayedFlagshipProperties);
    [self updateSet: notification.object];
}

-(void)shipChanged:(NSNotification*)notification
{
    NSArray* displayedShipProperties = @[
        @"ability",
        @"agility",
        @"attack",
        @"capabilities",
        @"cost",
        @"formattedFrontArc",
        @"formattedRearArc",
        @"hull",
        @"shield",
        @"title",
    ];
    self.currentShip = copyProperties(notification.object, displayedShipProperties);
    _moveGrid.ship = notification.object;
    [self updateSet: notification.object];
}

-(void)resourceChanged:(NSNotification*)notification
{
    NSArray* displayedResourceProperties = @[
        @"ability",
        @"cost",
        @"title",
    ];
    self.currentResource = copyProperties(notification.object, displayedResourceProperties);
    [self updateSet: notification.object];
}

-(void)referenceChanged:(NSNotification*)notification
{
    NSArray* displayedReferenceProperties = @[
        @"ability",
        @"title",
    ];
    self.currentReference = copyProperties(notification.object, displayedReferenceProperties);
    [self updateSet: notification.object];
}

-(void)topTabChanged:(NSNotification*)notification
{
//    id responder = [_mainWindow firstResponder];
//    NSString* ident = [responder identifier];
}

@end
