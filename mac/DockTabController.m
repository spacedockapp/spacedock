#import "DockTabController.h"

#import "DockAppDelegate.h"
#import "DockComponent+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip+MacAddons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockErrors.h"
#import "DockSearchFieldController.h"
#import "DockSquad+Addons.h"
#import "DockSet+Addons.h"
#import "DockComponent+Addons.h"
#import "DockUtilsMac.h"

@interface DockTabController ()
@property (assign) NSTableView* targetTable;
@property (strong, nonatomic) NSString* currentSearchTerm;
@end

@implementation DockTabController

#pragma mark - Setup

NSMutableArray* sTabControllers = nil;

+(void)initialize
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sTabControllers = [[NSMutableArray alloc] init];
    });
}

+(NSArray*)allTabControllers
{
    return [NSArray arrayWithArray: sTabControllers];
}

+(DockTabController*)tabControllerForIdentifier:(NSString*)identifier
{
    for (DockTabController* tc in sTabControllers) {
        if ([tc.targetTab.identifier isEqualToString: identifier]) {
            return tc;
        }
    }
    return nil;
}

-(void)awakeFromNib
{
    assert(self.appDelegate != nil);
    assert(self.targetController != nil);
    assert(self.targetTab != nil);
    [super awakeFromNib];
    self.searchResultsCount = -1;
    self.originalTitle = _targetTab.label;
    [sTabControllers addObject: self];
    _targetTable = findFirstTableView(self.targetTab.view);
    assert(self.targetTable != nil);
    [self setupSortDescriptors];
    [self updatePredicates];
    [self setupCurrrentTargetShip];
    [self startObserving];
}

#pragma mark - sorting

-(NSArray*)createSortDescriptors
{
    return @[[[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES]];
}

-(void)setupSortDescriptors
{
    NSArray* defaultSortDescriptors = [self createSortDescriptors];
    [self.targetTable setSortDescriptors: defaultSortDescriptors];
    [self.targetController setSortDescriptors: defaultSortDescriptors];
    [self.targetController rearrangeObjects];
}

#pragma mark - Filtering

-(BOOL)managesSetItems
{
    return YES;
}

-(NSArray*)includedSets
{
    return self.appDelegate.includedSets;
}

-(NSString*)factionName
{
    return self.appDelegate.factionName;
}

-(BOOL)dependsOnFaction
{
    return YES;
}

-(void)addPartsForIncludedSets:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    NSArray* includedSets = [self includedSets];
    if (includedSets.count > 0) {
        [formatParts addObject: @"(any sets.externalId in %@)"];
        [arguments addObject: self.includedSets];
    }
}

-(void)addAdditionalPredicatesForFaction:(NSString*)factionName formatParts:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    if (self.dependsOnFaction && factionName != nil) {
        [formatParts addObject: @"(ANY categories.type like %@ and ANY categories.value like %@)"];
        [arguments addObject: kDockFactionCategoryType];
        [arguments addObject: factionName];
    }
}

-(void)addAdditionalPredicates:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
}

-(void)addAdditionalPredicatesForSearchTerm:(NSString*)searchTerm formatParts:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    [formatParts addObject: @"(title contains[cd] %@)"];
    [arguments addObject: searchTerm];
}

-(void)updatePredicates
{
    NSMutableArray* formatParts = [NSMutableArray arrayWithCapacity: 0];
    NSMutableArray* arguments = [NSMutableArray arrayWithCapacity: 0];

    if (self.managesSetItems) {
        [self addPartsForIncludedSets:formatParts arguments:arguments];
    }

    NSString* factionName = [self factionName];
    if (factionName != nil) {
        [self addAdditionalPredicatesForFaction: self.factionName formatParts: formatParts arguments: arguments];
    }

    if (_currentSearchTerm.length > 0) {
        [self addAdditionalPredicatesForSearchTerm: _currentSearchTerm formatParts: formatParts arguments:arguments];
    }

    [self addAdditionalPredicates:formatParts arguments:arguments];

    NSString* formatString = [formatParts componentsJoinedByString: @" and "];
    if (formatString.length > 0) {
        NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: formatString argumentArray: arguments];
        self.targetController.fetchPredicate = predicateTemplate;
    } else {
        self.targetController.fetchPredicate = nil;
    }

    [self.targetController rearrangeObjects];
    [self.targetTable reloadData];

}

-(void)currentSearchTermChanged:(NSString*)searchTerm
{
    if (![_currentSearchTerm isEqualToString: searchTerm]) {
        _currentSearchTerm = searchTerm;
        [self updatePredicates];
    }
}

#pragma mark - Current Ship

-(BOOL)dependsOnCurrentTargetShip
{
    return NO;
}

-(void)currentTargetShipChanged
{
    NSIndexSet* rows = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, self.targetTable.numberOfRows)];
    NSIndexSet* cols = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, self.targetTable.numberOfColumns)];
    [self.targetTable reloadDataForRowIndexes: rows columnIndexes: cols];
    [self.targetController rearrangeObjects];
}

-(void)setupCurrrentTargetShip
{
    if ([self dependsOnCurrentTargetShip]) {
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        id currentTargetChangedBlock = ^() {
            [self currentTargetShipChanged];
        };
        [center addObserverForName: kCurrentTargetShipChanged object: nil queue: nil usingBlock: currentTargetChangedBlock];
    }
}

# pragma mark - Table selection

-(NSString*)notificationName
{
    return nil;
}

-(void)handleSelectionChanged
{
    NSString* notificationName = [self notificationName];
    if (notificationName != nil) {
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        id currentItem = [self selectedItem];
        NSNotification* notification = [NSNotification notificationWithName: notificationName object: currentItem];
        [center postNotification: notification];
    }
}

-(id)selectedItemIfVisible
{
    NSTabViewItem* selectedTab = [self.targetTab.tabView selectedTabViewItem];
    id identifier = selectedTab.identifier;

    if ([identifier isEqualToString: self.targetTab.identifier]) {
        return [self selectedItem];
    }

    return nil;
}

-(id)selectedItem
{
    NSArray* selected = [self.targetController selectedObjects];

    if (selected.count > 0) {
        return selected[0];
    }

    return nil;
}

-(void)scrollRowToVisible:(NSTableView*)table
{
    [table scrollRowToVisible: [table selectedRow]];
}

-(void)doSelectIndex:(NSInteger)index
{
    if (index != NSNotFound) {
        [self.targetController setSelectionIndex: index];
        NSTableView* table = self.targetTable;
        [table selectRowIndexes: [NSIndexSet indexSetWithIndex: index] byExtendingSelection: NO];
        [table scrollRowToVisible: [table selectedRow]];
    }
}

#pragma mark - Showing items

-(NSInteger)indexOfItem:(id)item
{
    NSArray* objects = [self.targetController arrangedObjects];
    return [objects indexOfObject: item];
}

-(void)delayedSelectItem:(id)item
{
    NSInteger index = [self indexOfItem: item];
    [self doSelectIndex: index];
}

-(void)showItem:(id)item
{
    if (item) {
        NSTabView* tabView = self.targetTab.tabView;
        NSString* identifier = self.targetTab.identifier;
        [tabView selectTabViewItemWithIdentifier: identifier];
        NSInteger index = [self indexOfItem: item];
        if (index == NSNotFound) {
            [self resetFiltersForItem: item];
            index = [self indexOfItem: item];
        }
        if (index == NSNotFound) {
            // have to wait until the array controller re-fetches
            [self performSelector:@selector(delayedSelectItem:) withObject: item afterDelay: 0];
        } else {
            [self doSelectIndex: index];
        }
    }
}

-(BOOL)containsThisKind:(id)item
{
    return NO;
}

-(void)resetFiltersForItem:(id)item
{
    if ([self dependsOnFaction]) {
        NSString* filterFaction = [self factionName];
        if (![item hasFaction: filterFaction]) {
            self.appDelegate.factionName = nil;
            [self.targetController rearrangeObjects];
            [self.targetTable reloadData];
        }
    }
}

+(DockTabController*)tabControlerForItem:(id)item
{
    for (DockTabController* controller in sTabControllers) {
        if ([controller containsThisKind: item]) {
            return controller;
        }
    }
    return nil;
}

+(void)makeOneControllerShowItem:(id)item
{
    [[DockTabController tabControlerForItem: item] showItem: item];
}

#pragma mark - Add to ship

-(DockEquippedShip*)findEligibleShipForItem:(DockComponent*)item inSquad:(DockSquad*)squad
{
    for (DockEquippedShip* ship in squad.equippedShips) {
        if ([self canAddItem: item toShip: ship]) {
            return ship;
        }
    }
    return nil;
}

-(void)addSelectedToSquad:(DockSquad*)selectedSquad ship:(DockEquippedShip*)selectedShip selectedItem:(id)selectedItem
{
    NSArray* itemsToAdd = [self.targetController selectedObjects];

    if (itemsToAdd.count > 0) {
        DockComponent* item = itemsToAdd[0];
        if (selectedShip == nil) {
            selectedShip = [self findEligibleShipForItem: item inSquad: selectedSquad];
        }
        id result = [self addItem: item toShip: selectedShip inSquad: selectedSquad selectedItem: selectedItem];
        if (result != nil) {
            if ([result isKindOfClass: [DockEquippedUpgrade class]]) {
                [self.appDelegate selectUpgrade:(DockEquippedUpgrade*)result];
            }
        }
    }
}

-(BOOL)canAddItem:(DockComponent*)item toShip:(DockEquippedShip*)ship
{
    return YES;
}

-(DockEquippedUpgrade*)addItem:(DockComponent*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    return nil;
}

-(BOOL)shipIsEligible:(DockEquippedShip*)ship
{
    return YES;
}

-(void)alertDidEnd:(NSAlert*)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [[alert window] orderOut: self];
}

-(void)explainCantUniqueUpgrade:(NSError*)error
{
    NSDictionary* d = error.userInfo;

    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg = d[NSLocalizedDescriptionKey];
    if (msg) {
        [alert setMessageText: msg];
    }
    NSString* info = d[NSLocalizedFailureReasonErrorKey];
    if (info) {
        [alert setInformativeText: info];
    }
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: self.window
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(void)updateSearchResultsCount
{
    NSInteger count = [self.targetController.arrangedObjects count];
    if (count > 0 && _currentSearchTerm.length) {
        self.searchResultsCount = count;
    } else {
        self.searchResultsCount = -1;
    }
}

#pragma mark - Observing

-(void)startObserving
{
    [self.targetController addObserver: self forKeyPath: @"selectedObjects" options: 0 context: 0];
    [self.targetController addObserver: self forKeyPath: @"arrangedObjects" options: 0 context: 0];
    [self.appDelegate addObserver: self forKeyPath: @"includedSets" options: 0 context: 0];
    if ([self dependsOnFaction]) {
        [self.appDelegate addObserver: self forKeyPath: @"factionName" options: 0 context: 0];
    }
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    id currentSearchTermChangedBlock = ^(NSNotification* notification) {
        [self currentSearchTermChanged: notification.object];
    };
    [center addObserverForName: kCurrentSearchTerm object: nil queue: nil usingBlock: currentSearchTermChangedBlock];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.targetController) {
        if ([keyPath isEqualToString: @"selectedObjects"]) {
            [self handleSelectionChanged];
        } else if ([keyPath isEqualToString: @"arrangedObjects"]) {
            [self updateSearchResultsCount];
        }
    } else if (object == self.appDelegate) {
        if ([keyPath isEqualToString: @"factionName"] || [keyPath isEqualToString: @"includedSets"]) {
            [self updatePredicates];
        }
    }
}

#pragma mark - Properties

-(NSWindow*)window
{
    return self.targetTab.tabView.window;
}

@end
