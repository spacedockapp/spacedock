#import "DockTableViewController.h"

#import "DockSet+Addons.h"
#import "DockUtilsMobile.h"

@interface DockTableViewController ()
@end

@implementation DockTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        presentError(error);
    }
}

#pragma mark - Fetching

-(BOOL)useSetFilter
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
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSSortDescriptor *factionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"faction" ascending:YES];
    return @[factionDescriptor, titleDescriptor];
}

-(void)setupFetch:(NSFetchRequest*)fetchRequest context:(NSManagedObjectContext*)context
{
    NSString* entityName = [self entityName];
    NSEntityDescription *entity = [NSEntityDescription entityForName: entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors: [self sortDescriptors]];
    NSArray* includedSets = self.includedSets;
    if (includedSets) {
        NSPredicate* predicateTemplate= [NSPredicate predicateWithFormat: @"any sets.externalId in %@", includedSets];
        [fetchRequest setPredicate: predicateTemplate];
    }
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

- (NSFetchedResultsController *)fetchedResultsController {

    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if ([self useSetFilter]) {
        [self updateSelectedSets];
    }

    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [self setupFetch: fetchRequest context: self.managedObjectContext];

    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                    managedObjectContext: self.managedObjectContext
                                                                      sectionNameKeyPath: [self sectionNameKeyPath]
                                                                               cacheName: nil];
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

#pragma mark - Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: _cellIdentifer];
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

@end
