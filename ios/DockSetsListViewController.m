#import "DockSetsListViewController.h"

#import "DockSet+Addons.h"
#import "DockSetTableViewCell.h"
#import "DockUtilsMobile.h"

@interface DockSetsListViewController ()

@end

@implementation DockSetsListViewController

-(void)viewDidLoad
{
    self.cellIdentifer = @"Set";
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
    return nil;
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
    NSSortDescriptor* titleDescriptor = [[NSSortDescriptor alloc] initWithKey: @"externalId" ascending: YES];
    return @[titleDescriptor];
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
