#import "DockUpgradesViewController.h"

#import "DockEquippedUpgrade+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUpgradeDetailViewController.h"

@interface DockUpgradesViewController ()

@end

@implementation DockUpgradesViewController

- (void)viewDidLoad
{
    self.cellIdentifer = @"Upgrade";
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.title = _upType;
    [super viewWillAppear: animated];
}

-(NSString*)entityName
{
    return @"Upgrade";
}

-(void)setUpType:(NSString *)upType
{
    if (![_upType isEqualToString: upType]) {
        _upType = upType;
        self.navigationController.title = upType;
    }
    self.fetchedResultsController = nil;
}

-(void)setupFetch:(NSFetchRequest*)fetchRequest context:(NSManagedObjectContext*)context
{
    [super setupFetch: fetchRequest context: context];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"upType = %@ and not placeholder == YES", _upType];
    [fetchRequest setPredicate: predicateTemplate];
}

#pragma mark - Table view data source methods

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    DockUpgrade* upgrade = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [upgrade title];
    if (_targetShip) {
        BOOL canAdd = [_targetSquad canAddUpgrade: upgrade toShip: _targetShip error: nil];
        if (!canAdd) {
            cell.textLabel.textColor = [UIColor grayColor];
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        int actualCost = [upgrade costForShip: _targetShip];
        int cost = [[upgrade cost] intValue];
        if (cost == actualCost) {
            cell.detailTextLabel.text = [upgrade.cost stringValue];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%d (%@)", actualCost, upgrade.cost];
        }
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [[upgrade cost] stringValue];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_targetSquad) {
        DockUpgrade *upgrade = [self.fetchedResultsController objectAtIndexPath:indexPath];
        return [_targetSquad canAddUpgrade: upgrade toShip: _targetShip error: nil];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_targetSquad) {
        DockUpgrade *upgrade = [self.fetchedResultsController objectAtIndexPath:indexPath];
        _onUpgradePicked(upgrade);
        [self clearTarget];
    } else {
    }
}

-(void)targetSquad:(DockSquad*)squad onPicked:(DockUpgradePicked)onPicked
{
    _targetSquad = squad;
    _onUpgradePicked = onPicked;
}

-(void)clearTarget
{
    _targetSquad = nil;
    _targetShip = nil;
    _onUpgradePicked = nil;
}

-(void)targetSquad:(DockSquad*)squad ship:(DockEquippedShip*)ship onPicked:(DockUpgradePicked)onPicked
{
    _targetSquad = squad;
    _targetShip = ship;
    _onUpgradePicked = onPicked;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];
    if ([identifier isEqualToString:@"ShowUpgradeDetails"]) {
        DockUpgradeDetailViewController* controller = (DockUpgradeDetailViewController*)destination;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        DockUpgrade *upgrade = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.upgrade = upgrade;
    }
}

@end
