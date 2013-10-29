#import "DockEquippedShipController.h"

#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockUpgrade+Addons.h"

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

- (void)viewWillAppear:(BOOL)animated
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"upgrade";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger row = [indexPath indexAtPosition: 1];
    NSArray* group = _upgradeBuckets[section];
    DockEquippedUpgrade* equippedUpgrade = group[row];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
