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
        self.fetchedResultsController = nil;
        self.navigationController.title = upType;
    }
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
    if ([upgrade isUnique] && [_targetSquad containsUpgradeWithName: upgrade.title]) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_targetSquad) {
        DockUpgrade *upgrade = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([upgrade isUnique]) {
            return ![_targetSquad containsUpgradeWithName: upgrade.title];
        }
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
    _onUpgradePicked = nil;
}

@end
