#import "DockEquippedShipController.h"

#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUpgradesViewController.h"
#import "DockUtilsMobile.h"

@interface DockEquippedShipController ()
@property (strong, nonatomic) NSArray* upgradeBuckets;
@end

@implementation DockEquippedShipController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)createBuckets
{
    NSMutableArray* upgradeBuckets = [NSMutableArray arrayWithCapacity: 0];
    NSMutableArray* currentBucket = [NSMutableArray arrayWithCapacity: 0];
    NSArray* sortedUpgrades = _equippedShip.sortedUpgrades;
    DockEquippedUpgrade* firstUpgrade = sortedUpgrades.firstObject;
    NSString* lastUpgradeType = firstUpgrade.upgrade.upType;
    for (DockEquippedUpgrade* equippedUpgrade in _equippedShip.sortedUpgrades) {
        DockUpgrade* upgrade = equippedUpgrade.upgrade;
        if (![lastUpgradeType isEqualToString: upgrade.upType]) {
            if (currentBucket.count > 0) {
                [upgradeBuckets addObject: currentBucket];
            }
            currentBucket = [NSMutableArray arrayWithCapacity: 0];
            lastUpgradeType = [upgrade upType];
        }
        [currentBucket addObject: equippedUpgrade];
    }
    if (currentBucket.count > 0) {
        [upgradeBuckets addObject: currentBucket];
    }
    _upgradeBuckets = [NSArray arrayWithArray: upgradeBuckets];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self createBuckets];
    [super viewWillAppear: animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _upgradeBuckets.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray* group = _upgradeBuckets[section];
    DockEquippedUpgrade* equippedUpgrade = group.firstObject;
    DockUpgrade* upgrade = equippedUpgrade.upgrade;
    return upgrade.upType;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* group = _upgradeBuckets[section];
    return group.count;
}

-(DockEquippedUpgrade*)upgradeAtPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    if (section >= _upgradeBuckets.count) {
        return nil;
    }
    NSArray* group = _upgradeBuckets[section];
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row >= group.count) {
        return nil;
    }
    return group[row];
}

-(DockEquippedUpgrade*)selectedUpgrade
{
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    return [self upgradeAtPath: indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"upgrade";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    DockEquippedUpgrade* equippedUpgrade = [self upgradeAtPath: indexPath];
    DockUpgrade* upgrade = equippedUpgrade.upgrade;
    cell.textLabel.text = [upgrade title];
    if ([upgrade isPlaceholder]) {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", [equippedUpgrade cost]];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        DockEquippedUpgrade* equippedUpgrade = [self upgradeAtPath: indexPath];
        [_equippedShip removeUpgrade: equippedUpgrade establishPlaceholders: YES];
        NSError* error;
        if (!saveItem(_equippedShip, &error)) {
            presentError(error);
        }
        [self createBuckets];
        [tableView reloadData];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PickUpgrade"]) {
        DockEquippedUpgrade* oneToReplace = [self selectedUpgrade];
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController *)destination;
        controller.managedObjectContext = _equippedShip.managedObjectContext;
        controller.upType = [[[self selectedUpgrade] upgrade] upType];
        id onPick = ^(DockUpgrade* upgrade) {
            [self addUpgrade: upgrade replacing: oneToReplace];
        };
        [controller targetSquad: _equippedShip.squad onPicked: onPick];
    }
}

-(void)addUpgrade:(DockUpgrade*)upgrade replacing:(DockEquippedUpgrade*)oneToReplace
{
    [_equippedShip addUpgrade: upgrade maybeReplace: oneToReplace establishPlaceholders: YES];
    [self.navigationController popViewControllerAnimated:YES];
    NSError *error;
    if (!saveItem(_equippedShip, &error)) {
        presentError(error);
    }
    [self.tableView reloadData];
}

@end
