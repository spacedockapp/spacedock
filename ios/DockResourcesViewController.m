#import "DockResourcesViewController.h"

#import "DockDetailViewController.h"
#import "DockResource+Addons.h"
#import "DockSet+Addons.h"

NSString* kMarkExpiredResKey = @"markExpiredRes";

@interface DockResourcesViewController ()
@property (nonatomic, weak) DockSquad* targetSquad;
@property (nonatomic, weak) DockResource* targetResource;
@property (nonatomic, strong) DockResourcePicked onResourcePicked;
@property (nonatomic, assign) BOOL disclosureTapped;
@property (nonatomic, assign) BOOL markExpiredRes;
@end

@implementation DockResourcesViewController

-(void)viewDidLoad
{
    self.cellIdentifer = @"Resource";
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _markExpiredRes = [defaults boolForKey:kMarkExpiredResKey];
    
    _disclosureTapped = NO;
    [super viewWillAppear: animated];
    NSIndexPath* indexPath = nil;

    if (_targetResource) {
        indexPath = [self.fetchedResultsController indexPathForObject: _targetResource];
    } else if (_targetSquad) {
        NSArray* resources = self.fetchedResultsController.fetchedObjects;
        if (resources.count > 0) {
            indexPath = [NSIndexPath indexPathForRow: resources.count inSection: 0];
        }
    }

    if (indexPath != nil) {
        [self.tableView selectRowAtIndexPath: indexPath animated: YES scrollPosition: UITableViewScrollPositionMiddle];
    }
}

-(void)didReceiveMemoryWarning
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

-(BOOL)useFactionFilter
{
    return NO;
}

-(BOOL)useCostFilter
{
    return NO;
}

-(void)setupFetch:(NSFetchRequest*)fetchRequest context:(NSManagedObjectContext*)context
{
    [super setupFetch: fetchRequest context: context];
}

-(NSArray*)sortDescriptors
{
    NSSortDescriptor* titleDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES];
    return @[titleDescriptor];
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger actual = [super tableView: tableView numberOfRowsInSection: section];

    if (_targetSquad) {
        actual += 1;
    }

    return actual;
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    NSArray* resources = self.fetchedResultsController.fetchedObjects;

    if (row == resources.count) {
        cell.textLabel.text = @"No resource";
        cell.detailTextLabel.text = @" ";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        DockResource* resource = resources[row];
        cell.textLabel.text = [[resource title] stringByAppendingString:@"      "];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = [[resource costForSquad:_targetSquad] stringValue];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        if (_markExpiredRes) {
            DockSet* set = [resource.sets anyObject];
            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [cal components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:set.releaseDate];
            [components setDay:1];
            
            NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                               components:NSCalendarUnitMonth
                                               fromDate:[cal dateFromComponents:components]
                                               toDate:[NSDate date] options:0];
            if (ageComponents.month >= 18) {
                NSMutableAttributedString* as = [[NSMutableAttributedString alloc] initWithString:[resource title]];
                NSMutableAttributedString* exp = [[NSMutableAttributedString alloc] initWithString:@" (Retired)      "];
                [exp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[exp length])];
                [as appendAttributedString:exp];
                cell.textLabel.attributedText = as;
            } else if (ageComponents.month == 17) {
                NSMutableAttributedString* as = [[NSMutableAttributedString alloc] initWithString:[resource title]];
                NSMutableAttributedString* exp = [[NSMutableAttributedString alloc] initWithString:@" (Retiring)      "];
                [exp addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0,[exp length])];
                [as appendAttributedString:exp];
                cell.textLabel.attributedText = as;
            }
        }
    }
    if (_targetSquad == nil) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (_targetSquad) {
        NSInteger row = [indexPath indexAtPosition: 1];
        NSArray* resources = self.fetchedResultsController.fetchedObjects;
        DockResource* resource = nil;

        if (row < resources.count) {
            resource = resources[row];
        }

        _onResourcePicked(resource);
        [self clearTarget];
    } else {
        [self performSegueWithIdentifier: @"ShowResourceDetails" sender: self];
    }
}

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    _disclosureTapped = YES;
    [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionMiddle];
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

-(BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];

    if ([identifier isEqualToString: @"ShowResourceDetails"]) {
        DockDetailViewController* controller = (DockDetailViewController*)destination;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject* target = [self.fetchedResultsController objectAtIndexPath: indexPath];
        controller.target = target;
    }
}

@end
