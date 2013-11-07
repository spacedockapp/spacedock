#import "DockResourcesViewController.h"

#import "DockResource.h"

@interface DockResourcesViewController ()

@end

@implementation DockResourcesViewController

- (void)viewDidLoad
{
    self.cellIdentifer = @"Resource";
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSString*)entityName
{
    return @"Resource";
}

-(NSString*)sectionNameKeyPath
{
    return nil;
}

-(void)setupFetch:(NSFetchRequest*)fetchRequest context:(NSManagedObjectContext*)context
{
    [super setupFetch: fetchRequest context: context];
}

-(NSArray*)sortDescriptors
{
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    return @[titleDescriptor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DockResource* resource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [resource title];
    cell.detailTextLabel.text = [resource.cost stringValue];
}
@end
