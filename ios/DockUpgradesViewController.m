#import "DockUpgradesViewController.h"

#import "DockEquippedUpgrade+Addons.h"
#import "DockSquad+Addons.h"
#import "DockShip+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUpgradeDetailViewController.h"
#import "DockUtilsMobile.h"

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
    NSIndexPath* indexPath = nil;
    if (_targetUpgrade) {
        if (![_targetUpgrade isPlaceholder]) {
            indexPath = [self.fetchedResultsController indexPathForObject: _targetUpgrade];
        }
    }

    if (indexPath == nil && _targetShip) {
        NSString* faction = _targetShip.ship.faction;
        NSArray* sectionTitles = self.fetchedResultsController.sections;
        id titleCheck = ^(id obj, NSUInteger idx, BOOL *stop) {
            id<NSFetchedResultsSectionInfo> sectionInfo = obj;
            return [[sectionInfo name] isEqualToString: faction];
        };
        NSInteger section = [sectionTitles indexOfObjectPassingTest: titleCheck];
        indexPath = [NSIndexPath indexPathForRow: 0 inSection: section];
    }
    
    if (indexPath != nil) {
        [self.tableView selectRowAtIndexPath: indexPath animated: YES scrollPosition: UITableViewScrollPositionMiddle];
    }
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

-(void)explainCantAddUpgrade:(NSError*)error
{
    NSDictionary* d = [error userInfo];
    UIAlertView* view = [[UIAlertView alloc] initWithTitle: d[NSLocalizedDescriptionKey]
        message: d[NSLocalizedFailureReasonErrorKey]
        delegate: nil
        cancelButtonTitle: nil
        otherButtonTitles: @"OK", nil];
    [view show];
}

#pragma mark - Table view data source methods

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    DockUpgrade* upgrade = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [upgrade title];
    if (_targetShip) {
        BOOL canAdd = [_targetSquad canAddUpgrade: upgrade toShip: _targetShip error: nil];
        if (!canAdd && (_targetUpgrade != upgrade)) {
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
        NSError* error;
        if (_targetUpgrade == upgrade || [_targetSquad canAddUpgrade: upgrade toShip: _targetShip error: &error]) {
            return YES;
        }
        [self explainCantAddUpgrade: error];
        return NO;
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
        [self performSegueWithIdentifier: @"ShowUpgradeDetails" sender: self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition:UITableViewScrollPositionMiddle];
    [self performSegueWithIdentifier: @"ShowUpgradeDetails" sender: self];
}

-(void)targetSquad:(DockSquad*)squad onPicked:(DockUpgradePicked)onPicked
{
    [self targetSquad: squad ship: nil upgrade: nil onPicked: onPicked];
}

-(void)clearTarget
{
    _targetSquad = nil;
    _targetShip = nil;
    _targetUpgrade = nil;
    _onUpgradePicked = nil;
}

-(void)targetSquad:(DockSquad*)squad ship:(DockEquippedShip*)ship onPicked:(DockUpgradePicked)onPicked
{
    [self targetSquad: squad ship: ship upgrade: nil onPicked: onPicked];
}

-(void)targetSquad:(DockSquad*)squad ship:(DockEquippedShip*)ship upgrade:(DockUpgrade*)upgrade onPicked:(DockUpgradePicked)onPicked
{
    _targetSquad = squad;
    _targetShip = ship;
    _targetUpgrade = upgrade;
    _onUpgradePicked = onPicked;
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
    if ([identifier isEqualToString:@"ShowUpgradeDetails"]) {
        DockUpgradeDetailViewController* controller = (DockUpgradeDetailViewController*)destination;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        DockUpgrade *upgrade = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.upgrade = upgrade;
    }
}

@end
