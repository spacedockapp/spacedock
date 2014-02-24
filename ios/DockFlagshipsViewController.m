#import "DockFlagshipsViewController.h"

#import "DockFlagship+Addons.h"
#import "DockDetailViewController.h"

@class DockShip;
@class DockSquad;

@interface DockFlagshipsViewController ()
@property (nonatomic, strong) DockFlagshipPicked onFlagshipPicked;
@property (nonatomic, weak) DockShip* targetShip;
@property (nonatomic, weak) DockSquad* targetSquad;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* noneItem;
@end

@implementation DockFlagshipsViewController

-(void)viewDidLoad
{
    self.cellIdentifer = @"flagship";
    [super viewDidLoad];
}

-(NSString*)entityName
{
    return @"Flagship";
}

- (NSPredicate *)makePredicateTemplate
{
    NSString* faction = self.faction;
    if (faction != nil && [self useFactionFilter]) {
        NSArray* includedSets = self.includedSets;
        return [NSPredicate predicateWithFormat: @"faction in %@ and any sets.externalId in %@", @[faction, @"Independent"], includedSets];
    }
    return [super makePredicateTemplate];
}


// Customize the appearance of table view cells.
-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    DockFlagship* flagship = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = flagship.name;
    BOOL canAdd = _targetShip == nil || [flagship compatibleWithShip: _targetShip];

    if (!canAdd) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (_targetSquad) {
        DockFlagship* flagship = [self.fetchedResultsController objectAtIndexPath: indexPath];
        return [flagship compatibleWithShip: _targetShip];
    }
    
    return YES;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (_targetSquad) {
        DockFlagship* flagship = [self.fetchedResultsController objectAtIndexPath: indexPath];
        _onFlagshipPicked(flagship);
        [self clearTarget];
    } else {
        [self performSegueWithIdentifier: @"ShowFlagshipDetails" sender: self];
    }
}

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionMiddle];
    [self performSegueWithIdentifier: @"ShowFlagshipDetails" sender: self];
}

-(void)targetSquad:(DockSquad*)squad ship:(DockShip*)ship onPicked:(DockFlagshipPicked)onPicked
{
    _targetSquad = squad;
    _targetShip = ship;
    _onFlagshipPicked = onPicked;
}

-(void)clearTarget
{
    _targetSquad = nil;
    _onFlagshipPicked = nil;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];

    if ([identifier isEqualToString: @"ShowFlagshipDetails"]) {
        DockDetailViewController* controller = (DockDetailViewController*)destination;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject* target = [self.fetchedResultsController objectAtIndexPath: indexPath];
        controller.target = target;
    }
}

-(IBAction)clearFlagship:(id)sender
{
    if (_targetSquad) {
        _onFlagshipPicked(nil);
        [self clearTarget];
    }
}

@end
