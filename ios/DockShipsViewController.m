#import "DockShipsViewController.h"

#import "DockEquippedShip+Addons.h"
#import "DockShipDetailViewController.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"

@interface DockShipsViewController ()
@property (nonatomic, strong) DockShipPicked onShipPicked;
@property (nonatomic, weak) DockShip *targetShip;
@property (nonatomic, weak) DockSquad *targetSquad;
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
    [super viewWillAppear: animated];

    NSIndexPath* indexPath = nil;

    if (_targetShip) {
        indexPath = [self.fetchedResultsController indexPathForObject: _targetShip];
    }

    if (indexPath != nil) {
        [self.tableView selectRowAtIndexPath: indexPath animated: YES scrollPosition: UITableViewScrollPositionMiddle];
    }
}

#pragma mark - Table view data source methods

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    DockShip *ship = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = ship.title;
    if ([ship isUnique]) {
        if (_targetSquad) {
            if (_targetShip != ship && [_targetSquad containsShip: ship]) {
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
        if (_targetShip != ship && [ship isUnique]) {
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
    [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition:UITableViewScrollPositionMiddle];
    [self performSegueWithIdentifier: @"ShowShipDetails" sender: self];
}

-(void)targetSquad:(DockSquad*)squad onPicked:(DockShipPicked)onPicked
{
    [self targetSquad: squad ship: nil onPicked: onPicked];
}

-(void)targetSquad:(DockSquad*)squad ship:(DockShip*)ship onPicked:(DockShipPicked)onPicked
{
    _targetSquad = squad;
    _targetShip = ship;
    _onShipPicked = onPicked;
}

-(void)clearTarget
{
    _targetSquad = nil;
    _onShipPicked = nil;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];
    if ([identifier isEqualToString:@"ShowShipDetails"]) {
        DockShipDetailViewController* controller = (DockShipDetailViewController*)destination;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        DockShip *ship = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.ship = ship;
    }
}

@end
