#import "DockUpgradesViewController.h"

#import "DockEquippedUpgrade+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

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
    cell.detailTextLabel.text = [[upgrade cost] stringValue];
    BOOL canAdd = [_targetSquad canAddUpgrade: upgrade toShip: _targetShip error: nil];
    if (!canAdd) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
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

@end
