#import "DockResourcesViewController.h"

#import "DockDetailViewController.h"
#import "DockResource.h"

@interface DockResourcesViewController ()
@property (nonatomic, weak) DockSquad *targetSquad;
@property (nonatomic, weak) DockResource *targetResource;
@property (nonatomic, strong) DockResourcePicked onResourcePicked;
@property (nonatomic, assign) BOOL disclosureTapped;
@end

@implementation DockResourcesViewController

- (void)viewDidLoad
{
    self.cellIdentifer = @"Resource";
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    _disclosureTapped = NO;
    [super viewWillAppear: animated];
    NSIndexPath* indexPath = nil;
    if (_targetResource) {
        indexPath = [self.fetchedResultsController indexPathForObject: _targetResource];
    } else if (_targetSquad) {
        NSArray* resources = self.fetchedResultsController.fetchedObjects;
        indexPath = [NSIndexPath indexPathForRow: resources.count inSection: 0];
    }

    if (indexPath != nil) {
        [self.tableView selectRowAtIndexPath: indexPath animated: YES scrollPosition: UITableViewScrollPositionMiddle];
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger actual = [super tableView:tableView numberOfRowsInSection: section];
    if (_targetSquad) {
        actual += 1;
    }
    return actual;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    NSArray* resources = self.fetchedResultsController.fetchedObjects;
    if (row == resources.count) {
        cell.textLabel.text = @"No resource";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        DockResource* resource = resources[row];
        cell.textLabel.text = [resource title];
        cell.detailTextLabel.text = [resource.cost stringValue];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_targetSquad) {
        NSInteger row = [indexPath indexAtPosition: 1];
        NSArray* resources = self.fetchedResultsController.fetchedObjects;
        DockResource *resource = nil;
        if (row < resources.count) {
            resource = resources[row];
        }
        _onResourcePicked(resource);
        [self clearTarget];
    } else {
        [self performSegueWithIdentifier: @"ShowResourceDetails" sender: self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _disclosureTapped = YES;
    [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition:UITableViewScrollPositionMiddle];
    [self performSegueWithIdentifier: @"ShowResourceDetails" sender: self];
}

-(void)clearTarget
{
    _targetSquad = nil;
    _targetResource = nil;
    _onResourcePicked = nil;
}

-(void)targetSquad:(DockSquad*)squad resource:(DockResource*)resource onPicked:(DockResourcePicked)onPicked
{
    _targetResource = resource;
    _targetSquad = squad;
    _onResourcePicked = onPicked;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];
    if ([identifier isEqualToString:@"ShowResourceDetails"]) {
        DockDetailViewController* controller = (DockDetailViewController*)destination;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *target = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.target = target;
    }
}

@end
