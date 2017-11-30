#import "DockShipsViewController.h"

#import "DockSet+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockResource+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipDetailViewController.h"
#import "DockSquad+Addons.h"

@interface DockShipsViewController ()
@property (nonatomic, strong) DockShipPicked onShipPicked;
@property (nonatomic, weak) DockShip* targetShip;
@property (nonatomic, weak) DockSquad* targetSquad;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* factionBarItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* toggleButtonItem;
@end

@implementation DockShipsViewController

-(void)viewDidLoad
{
    self.cellIdentifer = @"Ship";
    [super viewDidLoad];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)entityName
{
    return @"Ship";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

    NSIndexPath* indexPath = nil;

    if (_targetShip) {
        indexPath = [self.fetchedResultsController indexPathForObject: _targetShip];
    }

    if (self.targetSet != nil) {
        NSSet* items = [self.targetSet items];
        NSUInteger resources = [[[items objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return [[obj class] isSubclassOfClass:[DockResource class]];
        }] allObjects] count];
        if (resources > 0) {
            _factionBarItem.title = @"Resources";
            _factionBarItem.enabled = YES;
            [_factionBarItem setAction:@selector(switchView:)];
        } else {
            _factionBarItem.title = nil;
            _factionBarItem.enabled = NO;
        }
        _toggleButtonItem.title = nil;
        _toggleButtonItem.enabled = NO;
    }
    
    if (indexPath != nil) {
        [self.tableView selectRowAtIndexPath: indexPath animated: YES scrollPosition: UITableViewScrollPositionMiddle];
    }
}

-(NSArray*)sortDescriptors
{
    NSSortDescriptor* titleDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES];
    NSSortDescriptor* classDescriptor = [[NSSortDescriptor alloc] initWithKey: @"shipClass" ascending: YES];
    NSSortDescriptor* uniqueDescriptor = [[NSSortDescriptor alloc] initWithKey: @"unique" ascending: NO];
    NSSortDescriptor* factionDescriptor = [[NSSortDescriptor alloc] initWithKey: @"faction" ascending: YES];
    return @[factionDescriptor, classDescriptor, uniqueDescriptor, titleDescriptor];
}

#pragma mark - Fetching
- (NSPredicate *)makePredicateTemplate
{
    NSString* faction = self.faction;
    NSArray* includedSets = self.includedSets;
    NSMutableArray* predicateTerms = [NSMutableArray arrayWithCapacity: 0];
    NSMutableArray* predicateValues = [NSMutableArray arrayWithCapacity: 0];
    [predicateTerms addObject: @"any sets.externalId in %@"];
    [predicateValues addObject: includedSets];
    if (faction != nil && [self useFactionFilter] && self.targetSet == nil) {
        [predicateTerms addObject: @"(faction = %@ or additionalFaction = %@)"];
        [predicateValues addObject: faction];
        [predicateValues addObject: faction];
    }
    
    int cost = self.cost;
    if (cost != 0 && [self useCostFilter]) {
        [predicateTerms addObject: @"cost <= %@"];
        [predicateValues addObject: [NSNumber numberWithInt: cost]];
    }
    
    NSString* searchTerm = self.searchTerm;
    if (searchTerm != nil) {
        [predicateTerms addObject: @"((title contains[cd] %@ and (unique == TRUE or mirrorUniverseUnique == TRUE)) or (shipClass contains[cd] %@ and unique == FALSE and mirrorUniverseUnique == FALSE))"];
        [predicateValues addObject: searchTerm];
        [predicateValues addObject: searchTerm];
    }
    
    NSString* predicateTermString = [predicateTerms componentsJoinedByString: @" and "];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat: predicateTermString argumentArray: predicateValues];
    
    return predicateTemplate;
}


#pragma mark - Table view data source methods

// Customize the appearance of table view cells.
-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{

    // Configure the cell to show the book's title
    DockShip* ship = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = ship.descriptiveTitle;
    cell.detailTextLabel.text = [ship.cost stringValue];
    if ([ship isAnyKindOfUnique]) {
        if (_targetSquad) {
            if (_targetShip != ship && [_targetSquad containsShip: ship]) {
                cell.textLabel.textColor = [UIColor grayColor];
            } else {
                cell.textLabel.textColor = [UIColor blackColor];
            }
        }
    }
    
    if (_targetSquad == nil) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (_targetSquad) {
        DockShip* ship = [self.fetchedResultsController objectAtIndexPath: indexPath];

        if (_targetShip != ship && [ship isAnyKindOfUnique]) {
            return ![_targetSquad containsShip: ship];
        }
    }

    return YES;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (_targetSquad) {
        DockShip* ship = [self.fetchedResultsController objectAtIndexPath: indexPath];
        _onShipPicked(ship);
        [self clearTarget];
    } else {
        [self performSegueWithIdentifier: @"ShowShipDetails" sender: self];
    }
}

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionMiddle];
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

-(BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    return NO;
}

-(void)switchView:(id)sender
{
    if ([sender class] == [UIBarButtonItem class]) {
        UIBarButtonItem* btn = sender;
        if ([btn.title isEqualToString:@"Resources"]) {
            [self performSegueWithIdentifier:@"ResourceList" sender:sender];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];

    if ([identifier isEqualToString: @"ShowShipDetails"]) {
        DockShipDetailViewController* controller = (DockShipDetailViewController*)destination;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        DockShip* ship = [self.fetchedResultsController objectAtIndexPath: indexPath];
        controller.ship = ship;
    }
    if ([[segue identifier] isEqualToString: @"ResourceList"]) {
        id destination = [segue destinationViewController];
        DockTableViewController* controller = (DockTableViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.targetSet = self.targetSet;
        controller.title = @"Resources";
    }
}

@end
