#import "DockSetsListViewController.h"

#import "DockSet+Addons.h"
#import "DockSetTableViewCell.h"
#import "DockUtilsMobile.h"

@interface DockSetsListViewController ()
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@end

@implementation DockSetsListViewController

-(void)viewDidLoad
{
    self.cellIdentifer = @"Set";
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSArray* items = [self.fetchedResultsController fetchedObjects];

    for (DockSet* set in items) {
        if ([set.include boolValue]) {
            NSIndexPath* indexPath = [self.fetchedResultsController indexPathForObject: set];
            [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionNone];
        }
    }
    
    if ([DockSet includedSets:self.managedObjectContext].count > 0) {
        self.selectNone.enabled = YES;
    } else {
        self.selectNone.enabled = NO;
    }
    
    if ([DockSet includedSets:self.managedObjectContext].count == [DockSet allSets:self.managedObjectContext].count ) {
        self.selectAll.enabled = NO;
    } else {
        self.selectAll.enabled = YES;
    }

    [super viewWillAppear: animated];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSString*)entityName
{
    return @"Set";
}

-(NSString*)sectionNameKeyPath
{
    return @"releaseDate";
}

-(BOOL)useSetFilter
{
    return NO;
}

-(void)setupFetch:(NSFetchRequest*)fetchRequest context:(NSManagedObjectContext*)context
{
    [super setupFetch: fetchRequest context: context];
}

-(NSArray*)sortDescriptors
{
    NSSortDescriptor* releaseDateDescriptor = [[NSSortDescriptor alloc] initWithKey: @"releaseDate" ascending: YES];
    NSSortDescriptor* titleDescriptor = [[NSSortDescriptor alloc] initWithKey: @"productName" ascending: YES];
    NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES];
    return @[releaseDateDescriptor, nameDescriptor, titleDescriptor];
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    DockSet* set = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.detailTextLabel.text = set.name;
    cell.textLabel.text = set.productName;
}

-(void)setIncludeSet:(DockSet*)set shouldInclude:(BOOL)shouldInclude
{
    NSError* error;
    set.include = [NSNumber numberWithBool: shouldInclude];

    if (!saveItem(set, &error)) {
        presentError(error);
    }
    
    if ([DockSet includedSets:self.managedObjectContext].count > 0) {
        self.selectNone.enabled = YES;
    } else {
        self.selectNone.enabled = NO;
    }
    
    if ([DockSet includedSets:self.managedObjectContext].count == [DockSet allSets:self.managedObjectContext].count ) {
        self.selectAll.enabled = NO;
    } else {
        self.selectAll.enabled = YES;
    }
}

-(IBAction)selectAll:(id)sender
{
    NSArray* allSets = [DockSet allSets:self.managedObjectContext];
    NSError* error;

    for (DockSet* s in allSets) {
        s.include = [NSNumber numberWithBool:YES];
    }

    if (![self.managedObjectContext save:&error]) {
        presentError(error);
    }
    [self.tableView reloadData];
    for (DockSet* s in allSets) {
        if ([s.include boolValue]) {
            NSIndexPath* indexPath = [self.fetchedResultsController indexPathForObject: s];
            [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionNone];
        }
    }
    self.selectAll.enabled = NO;
    self.selectNone.enabled = YES;
}

-(IBAction)selectNone:(id)sender
{
    NSArray* allSets = [DockSet allSets:self.managedObjectContext];
    NSError* error;
    
    for (DockSet* s in allSets) {
        s.include = [NSNumber numberWithBool:NO];
    }
    
    if (![self.managedObjectContext save:&error]) {
        presentError(error);
    }
    [self.tableView reloadData];
    self.selectNone.enabled = NO;
    self.selectAll.enabled = YES;
}


-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSIndexPath* firstObjectIndex = [NSIndexPath indexPathForRow: 0 inSection: section];
    DockSet* set = [self.fetchedResultsController objectAtIndexPath: firstObjectIndex];
    return [self.dateFormatter stringFromDate: set.releaseDate];
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DockSet* set = [self.fetchedResultsController objectAtIndexPath: indexPath];
    [self setIncludeSet: set shouldInclude: YES];
}

-(void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DockSet* set = [self.fetchedResultsController objectAtIndexPath: indexPath];
    [self setIncludeSet: set shouldInclude: NO];
}

@end
