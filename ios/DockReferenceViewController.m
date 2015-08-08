#import "DockReferenceViewController.h"

#import "DockDetailViewController.h"
#import "DockReference.h"

@interface DockReferenceViewController ()

@end

@implementation DockReferenceViewController

-(void)viewDidLoad
{
    self.cellIdentifer = @"Reference";
    [super viewDidLoad];
}

-(NSString*)entityName
{
    return @"Reference";
}

-(NSString*)sectionNameKeyPath
{
    return @"type";
}

-(BOOL)useSetFilter
{
    return NO;
}

-(NSArray*)sortDescriptors
{
    NSSortDescriptor* titleDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES];
    NSSortDescriptor* typeDescriptor = [[NSSortDescriptor alloc] initWithKey: @"type" ascending: YES];
    return @[typeDescriptor, titleDescriptor];
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    DockReference* reference = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = reference.title;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
}

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionMiddle];
    [self performSegueWithIdentifier: @"ShowReferenceDetails" sender: self];
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];

    if ([identifier isEqualToString: @"ShowReferenceDetails"]) {
        DockDetailViewController* controller = (DockDetailViewController*)destination;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject* target = [self.fetchedResultsController objectAtIndexPath: indexPath];
        controller.target = target;
    }
}

@end
