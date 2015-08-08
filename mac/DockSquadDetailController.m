#import "DockSquadDetailController.h"

#import "DockAppDelegate.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip+MacAddons.h"
#import "DockEquippedFlagship.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockOverrideEditor.h"
#import "DockResourceTabController.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockTabControllerConstants.h"
#import "DockUpgrade+Addons.h"

#import "NSTreeController+Additions.h"

NSString* kCurrentEquippedUpgrade = @"CurrentEquippedUpgrade";

@interface DockSquadDetailController () <NSOutlineViewDelegate>
@property (assign, nonatomic) IBOutlet NSOutlineView* squadDetailView;
@property (assign, nonatomic) IBOutlet NSTreeController* squadDetailController;
@property (assign, nonatomic) IBOutlet NSArrayController* squadsController;
@property (assign, nonatomic) IBOutlet DockAppDelegate* appDelegate;
@property (strong, nonatomic) DockUpgrade* currentUpgrade;
@property (strong, nonatomic) DockShip* currentShip;
@end

@implementation DockSquadDetailController

-(void)awakeFromNib
{
    [super awakeFromNib];
    NSWindow* window = _squadDetailView.window;
    self.nextResponder = window.nextResponder;
    window.nextResponder = self;
    [_squadDetailController addObserver: self
                             forKeyPath: @"content"
                                options: 0
                                context: nil];
    [_squadDetailController addObserver: self
                             forKeyPath: @"arrangedObjects"
                                options: 0
                                context: nil];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(upgradeChanged:) name: kCurrentAdmiralChanged object: nil];
    [center addObserver: self selector: @selector(upgradeChanged:) name: kCurrentCaptainChanged object: nil];
    [center addObserver: self selector: @selector(upgradeChanged:) name: kCurrentUpgradeChanged object: nil];
    [center addObserver: self selector: @selector(shipChanged:) name: kCurrentShipChanged object: nil];
//    [center addObserver: self selector: @selector(resourceChanged:) name: kCurrentResourceChanged object: nil];
}

#pragma mark - Squads

-(DockSquad*)selectedSquad
{
    DockSquad* squad = nil;

    NSArray* squads = [_squadsController selectedObjects];

    if (squads.count > 0) {
        squad = [squads objectAtIndex: 0];
    }

    return squad;
}

#pragma mark - Equipped Ships

-(void)updateCurrentTargetShip
{
    DockEquippedShip* selectedES = [self selectedEquippedShip];
    [DockEquippedShip setCurrentTargetShip: selectedES];
}

-(DockEquippedShip*)equippedShipForTarget:(id)target
{
    if ([target isKindOfClass: [DockEquippedShip class]]) {
        return target;
    }

    if ([target isKindOfClass: [DockEquippedFlagship class]]) {
        return [target equippedShip];
    }

    if ([target isMemberOfClass: [DockEquippedUpgrade class]]) {
        DockEquippedUpgrade* upgrade = target;
        return upgrade.equippedShip;
    }

    return nil;
}

-(DockEquippedShip*)selectedEquippedShip
{
    NSArray* selectedShips = [_squadDetailController selectedObjects];

    if (selectedShips.count > 0) {
        id target = [[_squadDetailController selectedObjects] objectAtIndex: 0];
        
        return [self equippedShipForTarget: target];
    }

    return nil;
}

-(id)clickedSquadItem
{
    NSInteger index = [_squadDetailView clickedRow];
    if (index != -1) {
        id item = [_squadDetailView itemAtRow: index];
        return [item representedObject];
    }

    return nil;
}

-(DockEquippedShip*)clickedEquippedShip
{
    NSInteger index = [_squadDetailView clickedRow];
    if (index != -1) {
        id item = [_squadDetailView itemAtRow: index];
        return [self equippedShipForTarget: [item representedObject]];
    }

    return nil;
}

-(void)selectEquippedShip:(DockEquippedShip*)theShip
{
    NSIndexPath* path = [_squadDetailController indexPathOfObject: theShip];
    [_squadDetailController setSelectionIndexPath: path];
}

-(DockEquippedUpgrade*)selectedEquippedItem
{
    NSArray* selectedItems = [_squadDetailController selectedObjects];

    if (selectedItems.count > 0) {
        return [selectedItems objectAtIndex: 0];
    }

    return nil;
}

-(DockEquippedUpgrade*)selectedEquippedUpgrade
{
    id item = [self selectedEquippedItem];

    if ([item isMemberOfClass: [DockEquippedUpgrade class]]) {
        return item;
    }

    return nil;
}

-(void)selectUpgrade:(DockEquippedUpgrade*)theUpgrade
{
    NSIndexPath* path = [_squadDetailController indexPathOfObject: theUpgrade];
    [_squadDetailController setSelectionIndexPath: path];
}

-(IBAction)deleteTarget:(id)target targetShip:(DockEquippedShip*)targetShip
{
    if (target == targetShip) {
        DockSquad* squad = [[_squadsController selectedObjects] objectAtIndex: 0];
        [squad removeEquippedShip: targetShip];
    } else if ([target isKindOfClass: [DockEquippedFlagship class]]) {
        [targetShip removeFlagship];
    } else {
        [targetShip removeUpgrade: target establishPlaceholders: YES];
        [self selectEquippedShip: targetShip];
    }
}

-(IBAction)deleteSelected:(id)sender
{
    id target = [[_squadDetailController selectedObjects] objectAtIndex: 0];
    DockEquippedShip* targetShip = [self selectedEquippedShip];
    [self deleteTarget: target targetShip: targetShip];
    NSTableView* resTable = self.appDelegate.resourcesTableView;
    [resTable reloadData];
}

-(IBAction)deleteSelectedShip:(id)sender
{
    [self deleteSelected: sender];
    NSTableView* resTable = self.appDelegate.resourcesTableView;
    [resTable reloadData];
}

-(IBAction)changeSelectedShip:(id)sender
{
    DockEquippedShip* targetShip = [self selectedEquippedShip];
    DockShip* ship = [self selectedShip];
    [targetShip changeShip: ship];
}

-(void)alertDidEnd:(NSAlert*)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [[alert window] orderOut: self];
}

-(void)explainCantPromoteShip:(DockShip*)ship
{
    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg = [NSString stringWithFormat: @"Can't promote the selected ship to %@.", ship.title];
    [alert setMessageText: msg];
    NSString* info = [NSString stringWithFormat: @"%@ is unique and already exists in the squadron.", ship.title];
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: [self.squadDetailView window]
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(IBAction)toggleUnique:(id)sender
{
    DockEquippedShip* currentShip = [self selectedEquippedShip];

    if (currentShip != nil) {
        DockShip* ship = currentShip.ship;
        DockShip* counterpart = [ship counterpart];
        DockSquad* squad = [self selectedSquad];
        DockEquippedShip* existing = [squad containsShip: counterpart];

        if (existing != nil && [counterpart isUnique]) {
            [self explainCantPromoteShip: counterpart];
        } else {
            [currentShip changeShip: counterpart];
        }
    }
}

#pragma mark - Status

-(NSWindow*)window
{
    return self.squadDetailView.window;
}

-(BOOL)isFirstResponder
{
    return self.window.firstResponder == _squadDetailView;
}

-(BOOL)hasSelection;
{
    NSArray* selectedItems = [_squadDetailController selectedObjects];
    return (selectedItems.count > 0);
}

-(DockSetItem*)selectedItem
{
    return [[_squadDetailController selectedObjects] objectAtIndex: 0];
}

#pragma mark - Observing

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context
{
    if (object == _squadDetailController) {
        if ([keyPath isEqualToString: @"arrangedObjects"]) {
            [self updateCurrentTargetShip];
            [self publishEquippedItemNotification];
        } else {
            [_squadDetailView expandItem: nil
                          expandChildren: YES];
            [_squadDetailController removeObserver: self
                                        forKeyPath: @"content"];
        }
    }
}

-(void)upgradeChanged:(NSNotification*)notification
{
    self.currentUpgrade = notification.object;
}

-(void)shipChanged:(NSNotification*)notification
{
    self.currentShip = notification.object;
}

#pragma mark - Notifications

-(void)publishEquippedItemNotification
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    NSNotification* upgradeChangedNotification = [NSNotification notificationWithName: kCurrentEquippedUpgrade object: [self selectedEquippedItem]];
    [center postNotification: upgradeChangedNotification];
}

#pragma mark - Outline

-(IBAction)expandAll:(id)sender
{
    [_squadDetailView expandItem: nil expandChildren: YES];
}

#pragma mark - Contextual Menu

-(IBAction)showClickedInList:(id)sender
{
    id target = [self clickedSquadItem];
    DockEquippedShip* targetShip = [self clickedEquippedShip];
    [self.appDelegate showInList: target targetShip: targetShip];
}

-(IBAction)changeClickedShip:(id)sender
{
    DockEquippedShip* targetShip = [self clickedEquippedShip];
    DockShip* ship = [self selectedShip];
    [targetShip changeShip: ship];
}

-(IBAction)removeFlagship:(id)sender
{
    DockEquippedShip* targetShip = [self clickedEquippedShip];
    [targetShip removeFlagship];
}

-(IBAction)deleteClicked:(id)sender
{
    [self deleteTarget: [self clickedSquadItem] targetShip: [self clickedEquippedShip]];
}

-(IBAction)filterToClickedFaction:(id)sender
{
    [self.appDelegate updateFactionFilter: [[[self clickedEquippedShip] ship] faction]];
}

-(IBAction)filterToClickedUpgradeType:(id)sender
{
    [self.appDelegate.tabView selectTabViewItemWithIdentifier: @"upgrades"];
    DockUpgrade* upgrade = [[self clickedSquadItem] upgrade];
    [self.appDelegate updateUpgradeTypeFilter: [upgrade upType]];
}

-(IBAction)filterToClickedFactionAndUpgradeType:(id)sender
{
    [self.appDelegate.tabView selectTabViewItemWithIdentifier: @"upgrades"];
    [self filterToClickedFaction:sender];
    [self filterToClickedUpgradeType:sender];
}

-(IBAction)overrideClickedCost:(id)sender
{
    DockEquippedUpgrade* upgrade = [self clickedSquadItem];
    [self.appDelegate.overrideEditor show: upgrade];
}

-(IBAction)removeClickedOverride:(id)sender
{
    DockEquippedUpgrade* upgrade = [self clickedSquadItem];
    if (upgrade) {
        [upgrade removeCostOverride];
    }
}

static void addDeleteItem(NSMenu* menu)
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Delete" action: @selector(deleteClicked:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addFilterToFactionItem(NSMenu* menu, NSString* faction)
{
    if (faction == nil) {
        NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Filter to Faction" action: 0 keyEquivalent: @""];
        [menuItem setEnabled: NO];
        [menu addItem: menuItem];
        return;
    }
    NSString* menuTitle = [NSString stringWithFormat: @"Filter to Faction “%@”", faction];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: menuTitle action: @selector(filterToClickedFaction:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addFilterToTypeItem(NSMenu* menu, NSString* upType)
{
    NSString* menuTitle = [NSString stringWithFormat: @"Filter to Type “%@”", upType];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: menuTitle action: @selector(filterToClickedUpgradeType:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addFilterToFactionAndTypeItem(NSMenu* menu, NSString* faction, NSString* upType)
{
    if (faction == nil) {
        NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Filter to Faction and Type" action: 0 keyEquivalent: @""];
        [menuItem setEnabled: NO];
        [menu addItem: menuItem];
        return;
    }
    NSString* menuTitle = [NSString stringWithFormat: @"Filter to Faction “%@” and Type “%@”", faction, upType];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: menuTitle action: @selector(filterToClickedFactionAndUpgradeType:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addShowDetailsItem(NSMenu* menu)
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Show in List" action: @selector(showClickedInList:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

static void addOverrideItems(NSMenu* menu)
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Override Cost..." action: @selector(overrideClickedCost:) keyEquivalent: @""];
    [menu addItem: menuItem];
    menuItem = [[NSMenuItem alloc] initWithTitle: @"Remove Upgrade Cost Override" action: @selector(removeClickedOverride:) keyEquivalent: @""];
    [menu addItem: menuItem];
}

-(void)addChangeShipItem:(NSMenu *)menu
{
    DockEquippedShip* ship = [self clickedEquippedShip];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Change Ship" action: @selector(changeClickedShip:) keyEquivalent: @""];
    BOOL enabled = [self updateChangeShipItem: menuItem equippedShip: ship];
    if (enabled) {
        [menuItem setEnabled: enabled];
        [menuItem setTarget: self];
        [menu addItem: menuItem];
    } else {
        menuItem.target = nil;
    }
}

void addRemoveFlagshipItem(NSMenu *menu)
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle: @"Remove Flagship" action: @selector(removeFlagship:) keyEquivalent: @""];
    [menu addItem: menuItem];
    [menuItem setEnabled: YES];
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
    [menu removeAllItems];
    id target = [self clickedSquadItem];
    DockEquippedShip* targetShip = [self clickedEquippedShip];
    if (target != nil) {
        if (target == targetShip) {
            [self addChangeShipItem:menu];
            DockEquippedShip* ship = [self clickedEquippedShip];
            addShowDetailsItem(menu);
            addFilterToFactionItem(menu, ship.ship.faction);
            addDeleteItem(menu);
        } else if ([target isKindOfClass: [DockEquippedFlagship class]]) {
            addShowDetailsItem(menu);
            addRemoveFlagshipItem(menu);
        } else {
            DockEquippedUpgrade* eu = target;
            if (!eu.isPlaceholder) {
                addShowDetailsItem(menu);
            }
            addFilterToFactionItem(menu, eu.equippedShip.ship.faction);
            if (!eu.upgrade.isCaptain) {
                addFilterToTypeItem(menu, eu.upgrade.upType);
                addFilterToFactionAndTypeItem(menu, eu.equippedShip.ship.faction, eu.upgrade.upType);
                if (!eu.isPlaceholder) {
                    addOverrideItems(menu);
                }
            }
            if (!eu.isPlaceholder) {
                addDeleteItem(menu);
            }
        }
    }
}

#pragma mark - UI Validation

-(id)selectedShip
{
    return self.currentShip;
}

-(id)selectedUpgrade
{
    return self.currentUpgrade;
}

-(BOOL)updateChangeShipItem:(NSMenuItem*)menuItem equippedShip:(DockEquippedShip*)equippedShip
{
    DockShip* ship = [self selectedShip];

    if (ship && equippedShip) {
        [menuItem setTitle: [NSString stringWithFormat: @"Change '%@' to '%@'", equippedShip.descriptiveTitle, ship.descriptiveTitle]];
    } else {
        [menuItem setTitle: @"Change Ship"];
        return NO;
    }
    return YES;
}

-(BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
    SEL action = [menuItem action];

    if (action == @selector(addSelectedShip:)) {
        DockShip* ship = [self selectedShip];
        DockSquad* squad = [self selectedSquad];

        if (ship && squad) {
            [menuItem setTitle: [NSString stringWithFormat: @"Add '%@' to '%@'", ship.descriptiveTitle, squad.name]];
        } else {
            [menuItem setTitle: @"Add Ship to Squad"];
            return NO;
        }
    } else if (action == @selector(deleteSelectedShip:)) {
        DockEquippedShip* ship = [self selectedEquippedShip];
        DockSquad* squad = [self selectedSquad];

        if (ship && squad) {
            [menuItem setTitle: [NSString stringWithFormat: @"Remove '%@' from '%@'", ship.descriptiveTitle, squad.name]];
        } else {
            [menuItem setTitle: @"Delete Ship from Squad"];
            return NO;
        }
    } else if (action == @selector(changeSelectedShip:)) {
        DockEquippedShip* equippedShip = [self selectedEquippedShip];
        return [self updateChangeShipItem: menuItem equippedShip: equippedShip];
    } else if (action == @selector(addSelectedUpgradeAction:)) {
        DockEquippedShip* ship = [self selectedEquippedShip];
        DockUpgrade* upgrade = [self selectedUpgrade];

        if (ship && upgrade) {
            [menuItem setTitle: [NSString stringWithFormat: @"Add '%@' to '%@'", upgrade.title, ship.descriptiveTitle]];
            return YES;
        } else {
            [menuItem setTitle: @"Add Upgrade to Ship"];
            return NO;
        }
    } else if (action == @selector(toggleUnique:)) {
        DockEquippedShip* currentShip = [self selectedEquippedShip];

        if (currentShip == nil || currentShip.isFighterSquadron) {
            [menuItem setTitle: @"Demote"];
            return NO;
        }

        DockShip* ship = currentShip.ship;
        DockShip* counterpart = [ship counterpart];

        if ([ship isUnique]) {
            [menuItem setTitle: [NSString stringWithFormat: @"Demote to '%@'", counterpart.descriptiveTitle]];
        } else {
            [menuItem setTitle: [NSString stringWithFormat: @"Promote to '%@'", counterpart.descriptiveTitle]];
        }
    } else if (action == @selector(overrideCost:)) {
        DockEquippedUpgrade* upgrade = [self selectedEquippedUpgrade];
        return upgrade && ![upgrade.upgrade isCaptain];
    } else if (action == @selector(removeOverride:)) {
        DockEquippedUpgrade* upgrade = [self selectedEquippedUpgrade];
        return upgrade && [upgrade costIsOverridden];
    }

    return YES;
}

#pragma mark - Outline delegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    [self updateCurrentTargetShip];
    [self publishEquippedItemNotification];
}


@end
