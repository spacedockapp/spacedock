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
