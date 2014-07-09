#import "DockTableViewController.h"

#import "DockConstants.h"
#import "DockSet+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUtilsMobile.h"

@interface DockTableViewController () <UIActionSheetDelegate,UISearchBarDelegate>
@property (nonatomic, strong) IBOutlet UIBarButtonItem* factionBarItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* costBarItem;
@end

@implementation DockTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _faction = [defaults valueForKey: kSpaceDockFactionFilterKey];
    [self performFetch];
}

#pragma mark - Fetching

-(BOOL)useSetFilter
{
    return YES;
}

-(BOOL)useFactionFilter
{
    return YES;
}

-(BOOL)useCostFilter
{
    return YES;
}

-(NSString*)cacheName
{
    return @"Root";
}

-(NSString*)sectionNameKeyPath
{
    return @"faction";
}

-(NSString*)entityName
{
    return @"";
}

-(NSArray*)sortDescriptors
{
    NSSortDescriptor* titleDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES];
    NSSortDescriptor* factionDescriptor = [[NSSortDescriptor alloc] initWithKey: @"faction" ascending: YES];
    return @[factionDescriptor, titleDescriptor];
}

- (NSPredicate *)makePredicateTemplate
{
    NSString* faction = self.faction;
    NSArray* includedSets = self.includedSets;
    NSMutableArray* predicateTerms = [NSMutableArray arrayWithCapacity: 0];
    NSMutableArray* predicateValues = [NSMutableArray arrayWithCapacity: 0];

    [predicateTerms addObject: @"any sets.externalId in %@"];
    [predicateValues addObject: includedSets];
    if (faction != nil && [self useFactionFilter]) {
        [predicateTerms addObject: @"(faction = %@ or additionalFaction = %@)"];
        [predicateValues addObject: faction];
        [predicateValues addObject: faction];
    }

    int cost = self.cost;
    if (cost != 0 && [self useCostFilter]) {
        [predicateTerms addObject: @"cost = %@"];
        [predicateValues addObject: [NSNumber numberWithInt: cost]];
    }

    NSString* searchTerm = self.searchTerm;
    if (searchTerm != nil) {
        [predicateTerms addObject: @"title CONTAINS[CD] %@"];
        [predicateValues addObject: searchTerm];
    }

    NSString* predicateTermString = [predicateTerms componentsJoinedByString: @" and "];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat: predicateTermString argumentArray: predicateValues];

    return predicateTemplate;
}

-(void)setupFetch:(NSFetchRequest*)fetchRequest context:(NSManagedObjectContext*)context
{
    NSString* entityName = [self entityName];
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: self.managedObjectContext];
    [fetchRequest setEntity: entity];
    [fetchRequest setSortDescriptors: [self sortDescriptors]];
    NSArray* includedSets = self.includedSets;

    if (includedSets.count > 0) {
        NSPredicate* predicateTemplate = [self makePredicateTemplate];
        [fetchRequest setPredicate: predicateTemplate];
    }
}

-(id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger sectionIndex = indexPath.section;
    NSArray* sectionObjects = self.sectionLists[sectionIndex];
    return sectionObjects[indexPath.item];
}

-(void)updateSelectedSets
{
    NSArray* includedSets = [DockSet includedSets: _managedObjectContext];
    NSMutableArray* includedIds = [[NSMutableArray alloc] init];

    for (DockSet* set in includedSets) {
        [includedIds addObject: [set externalId]];
    }
    _includedSets = [NSArray arrayWithArray: includedIds];
}

-(NSFetchedResultsController*)fetchedResultsController
{

    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    if ([self useSetFilter]) {
        [self updateSelectedSets];
    }

    // Create and configure a fetch request with the Book entity.
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [self setupFetch: fetchRequest context: self.managedObjectContext];

    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                    managedObjectContext: self.managedObjectContext
                                                                      sectionNameKeyPath: [self sectionNameKeyPath]
                                                                               cacheName: nil];
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

-(void)clearFetch
{
    _fetchedResultsController = nil;
    [self performFetch];
    [self.tableView reloadData];
}

-(NSArray*)filterForCost:(NSArray*)rawList
{
    return [NSArray arrayWithArray: rawList];
}

-(void)performFetch
{
    NSError* error;

    if (![[self fetchedResultsController] performFetch: &error]) {
        presentError(error);
    }
    NSArray* originalSections = [self.fetchedResultsController sections];
    NSMutableArray* sectionLists = [NSMutableArray arrayWithCapacity: originalSections.count];
    for (id<NSFetchedResultsSectionInfo> sectionInfo in originalSections) {
        NSArray* sectionObjects = [self filterForCost: sectionInfo.objects];
        [sectionLists addObject: sectionObjects];
    }
    NSMutableArray* finalSections = [NSMutableArray arrayWithCapacity: sectionLists.count];
    NSMutableArray* finalSectionLists = [NSMutableArray arrayWithCapacity: sectionLists.count];
    for (int sectionIndex = 0; sectionIndex < sectionLists.count; ++sectionIndex) {
        NSArray* sectionObjects = sectionLists[sectionIndex];
        if (sectionObjects.count > 0) {
            [finalSectionLists addObject: sectionObjects];
            [finalSections addObject: originalSections[sectionIndex]];
        }
    }
    self.sections = [NSArray arrayWithArray: finalSections];
    self.sectionLists = [NSArray arrayWithArray: finalSectionLists];
}

#pragma mark - Table view data source methods

/*
   The data source methods are handled primarily by the fetch results controller
 */

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    NSInteger sectionCount = [self.sections count];
    return sectionCount;
}

// Customize the number of rows in the table view.
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* sectionObjectList = [[self sectionLists] objectAtIndex: section];
    return [sectionObjectList count];
}

// Customize the appearance of table view cells.
-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: _cellIdentifer];

    // Configure the cell.
    [self configureCell: cell atIndexPath: indexPath];
    return cell;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.sections objectAtIndex: section] name];
}

-(IBAction)faction:(id)sender
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: @"Faction"
                                                       delegate: self
                                              cancelButtonTitle: nil
                                         destructiveButtonTitle: nil
                                              otherButtonTitles: @"All", nil];
    NSSet* factionsSet = [DockUpgrade allFactions: self.managedObjectContext];
    NSArray* factionsArray = [[factionsSet allObjects] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    for (NSString* faction in factionsArray) {
        [sheet addButtonWithTitle: faction];
    }
    [sheet showFromBarButtonItem: _factionBarItem animated: YES];
}

-(IBAction)cost:(id)sender
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: @"Cost"
                                                       delegate: self
                                              cancelButtonTitle: nil
                                         destructiveButtonTitle: nil
                                              otherButtonTitles: @"All", nil];
    for (int i = 1; i < 8; ++i) {
        [sheet addButtonWithTitle: [NSString stringWithFormat: @"%d", i]];
    }
    [sheet showFromBarButtonItem: _costBarItem animated: YES];
}

-(void)updateFaction:(NSString*)faction
{
    _faction = faction;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: _faction forKey: kSpaceDockFactionFilterKey];
    [self clearFetch];
}

-(void)updateCost:(int)cost
{
    self.cost = cost;
    [self clearFetch];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* sheetTitle = actionSheet.title;
    if ([sheetTitle isEqualToString: @"Cost"]) {
        [self updateCost: (int)buttonIndex];
    } else {
        NSString* faction;
        switch (buttonIndex) {
        case 0:
            [self updateFaction: nil];
            break;

        default:
            faction = [actionSheet buttonTitleAtIndex: buttonIndex];
            [self updateFaction: faction];
            break;
        }
    }
}

#pragma mark - Search Bar methods


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        self.searchTerm = searchText;
    } else {
        self.searchTerm = nil;
    }
    [self clearFetch];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = nil;
    self.searchTerm = nil;
    [self clearFetch];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

@end
