#import "DockShipsViewController.h"

#import "DockEquippedShip+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"

@interface DockShipsViewController ()
@property (nonatomic, assign) BOOL disclosureTapped;
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

- (void)viewWillAppear:(BOOL)animated
{
    _disclosureTapped = NO;
    [super viewWillAppear: animated];
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
    } else {
        [self performSegueWithIdentifier: @"ShowShipDetails" sender: self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _disclosureTapped = YES;
    [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition:UITableViewScrollPositionMiddle];
    [self performSegueWithIdentifier: @"ShowShipDetails" sender: self];
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (_targetSquad) {
        return _disclosureTapped;
    }
    return YES;
}

@end
