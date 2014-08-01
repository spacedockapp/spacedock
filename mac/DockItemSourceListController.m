#import "DockItemSourceListController.h"

#import "DockTabController.h"
#import "DockTabDelegate.h"

@interface DockItemSourceListController() <NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (strong, nonatomic) NSArray* itemNames;
@property (strong, nonatomic) NSArray* groups;
@property (strong, nonatomic) NSArray* basics;
@property (strong, nonatomic) NSArray* extras;
@property (strong, nonatomic) NSArray* other;
@property (strong, nonatomic) NSDictionary* nameToIdent;
@property (strong, nonatomic) NSDictionary* identToName;
@property (strong, nonatomic) IBOutlet NSTabView* tabView;
@property (strong, nonatomic) IBOutlet NSOutlineView* outlineView;
@end

@implementation DockItemSourceListController

-(NSInteger)rowForName:(NSString*)itemName
{
    int index = 0;
    for (NSDictionary* d in _groups) {
        index += 1;
        NSArray* items = d[@"items"];
        for (NSString* name in items) {
            if ([name isEqualToString: itemName]) {
                return index;
            }
            index += 1;
        }
    }
    return NSNotFound;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DockTabController* controller = object;
    NSString* identifier = controller.targetTab.identifier;
    NSString* name = _identToName[identifier];
    NSInteger row = [self rowForName: name];
    if (row != NSNotFound) {
        [_outlineView reloadData];
    }
}

-(void)setupForTabs
{
    NSArray* tabs = [DockTabController allTabControllers];
    NSMutableDictionary* nameToIdent = [[NSMutableDictionary alloc] initWithCapacity: tabs.count];
    NSMutableDictionary* identToName = [[NSMutableDictionary alloc] initWithCapacity: tabs.count];
    for (DockTabController* tc in tabs) {
        nameToIdent[tc.targetTab.label] = tc.targetTab.identifier;
        identToName[tc.targetTab.identifier] = tc.targetTab.label;
        [tc addObserver: self forKeyPath: @"searchResultsCount" options: 0 context: 0];
    }
    _nameToIdent = [NSDictionary dictionaryWithDictionary: nameToIdent];
    _identToName = [NSDictionary dictionaryWithDictionary: identToName];
    [_outlineView reloadData];
    [self expand];
}

-(void)selectItemWithName:(NSString*)itemName
{
    NSInteger index = [self rowForName: itemName];
    if (index != NSNotFound) {
        [_outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: index] byExtendingSelection: NO];
    }
}

- (void)topTabChanged:(NSNotification*)notification
{
    NSString* identifier = [[_tabView selectedTabViewItem] identifier];
    NSString* name = _identToName[identifier];
    if (name) {
        [self selectItemWithName: name];
    }

}

-(void)expand
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [_outlineView expandItem:nil expandChildren:YES];
    [NSAnimationContext endGrouping];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    NSString* kUpgrades = @"Upgrades";
    _itemNames = @[
                   @"Ships",
                   @"Captains",
                   @"Fleet Captains",
                   kUpgrades,
                   @"Admirals",
                   @"Resources",
                   @"Flagships",
                   @"Sets",
                   @"Reference"
                   ];

    _basics = @[
                @"Ships", @"Captains", kUpgrades
                ];
    _extras = @[
                @"Fleet Captains", @"Admirals", @"Flagships", @"Resources"
                ];
    _other = @[
               @"Sets", @"Reference"
               ];
    _groups = @[
                @{@"name": @"Basics", @"items": _basics},
                @{@"name": @"Extras", @"items": _extras},
                @{@"name": @"Other", @"items": _other}
                ];

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(topTabChanged:) name: kTabSelectionChanged object: nil];
}

#pragma mark - Outline View

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item
{
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    BOOL isExpandable = NO;
    if ([outlineView parentForItem:item] == nil) {
        isExpandable = YES;
    }
    return isExpandable;
}

-(BOOL)isGroupItem:(id)item
{
    BOOL isGroupItem = (item != nil) && ([_groups containsObject: item]);
    return isGroupItem;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    NSInteger count = 0;

    if (item == nil) {
        count = [_groups count];
    } else if ([self isGroupItem: item]) {
        assert([item isKindOfClass: [NSDictionary class]]);
        NSDictionary* group = item;
        NSArray* groupItems = group[@"items"];
        assert([groupItems isKindOfClass: [NSArray class]]);
        count = groupItems.count;
    }

    return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    id childItem = nil;
    if (item == nil) {
        childItem = _groups[index];
    } else if ([self isGroupItem: item]) {
        assert([item isKindOfClass: [NSDictionary class]]);
        NSDictionary* group = item;
        NSArray* groupItems = group[@"items"];
        assert([groupItems isKindOfClass: [NSArray class]]);
        childItem = groupItems[index];
        assert([childItem isKindOfClass: [NSString class]]);
    }

    return childItem;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSString* identifier = tableColumn.identifier;
    if ([identifier isEqualToString: @"sourceLabel"]) {
        if ([self isGroupItem: item]) {
            NSTableCellView *result = [outlineView makeViewWithIdentifier:@"HeaderCell" owner: nil];
            result.textField.stringValue = [item objectForKey: @"name"];
            return result;
        }
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"DataCell" owner: nil];
        result.textField.stringValue = item;
        return result;
    }
    NSTableCellView *result = [outlineView makeViewWithIdentifier:@"DataCell" owner: nil];
    if ([self isGroupItem: item]) {
        result.textField.stringValue = @"";
    } else {
        NSString* identifier = _nameToIdent[item];
        DockTabController* tc = [DockTabController tabControllerForIdentifier: identifier];
        if (tc == nil) {
            NSLog(@"couldn't find tc %@ for item %@", identifier, item);
            result.textField.stringValue = @"";
        } else {
            NSInteger results = tc.searchResultsCount;
            NSLog(@"search results item:%@ ident: %@ is %ld", item, identifier, results);
            if (results < 1) {
                result.textField.stringValue = @"";
            } else {
                result.textField.stringValue = [NSString stringWithFormat: @"%ld", (long)results];
            }
        }
    }
    return result;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
{
    NSInteger selectionIndex = _outlineView.selectedRow;
    NSString* name = [_outlineView itemAtRow: selectionIndex];
    NSString* identifier = _nameToIdent[name];
    if (identifier) {
        [_tabView selectTabViewItemWithIdentifier: identifier];
    }
}

@end
