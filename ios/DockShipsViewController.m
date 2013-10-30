#import "DockShipsViewController.h"

#import "DockEquippedShip+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"

@interface DockShipsViewController ()
@end

@implementation DockShipsViewController

- (void)viewDidLoad
{
    self.cellIdentifer = @"Ship";
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)entityName
{
    return @"Ship";
}

#pragma mark - Table view data source methods

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    DockShip *ship = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = ship.title;
    if ([ship isUnique]) {
        if (_targetSquad) {
            if ([_targetSquad containsShip: ship]) {
                cell.textLabel.textColor = [UIColor grayColor];
            } else {
                cell.textLabel.textColor = [UIColor blackColor];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_targetSquad) {
        DockShip *ship = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([ship isUnique]) {
            return ![_targetSquad containsShip: ship];
        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_targetSquad) {
        DockShip *ship = [self.fetchedResultsController objectAtIndexPath:indexPath];
        _onShipPicked(ship);
        [self clearTarget];
    }
}

-(void)targetSquad:(DockSquad*)squad onPicked:(DockShipPicked)onPicked
{
    _targetSquad = squad;
    _onShipPicked = onPicked;
}

-(void)clearTarget
{
    _targetSquad = nil;
    _onShipPicked = nil;
}

@end
