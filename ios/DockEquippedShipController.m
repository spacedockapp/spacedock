#import "DockEquippedShipController.h"

#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagshipsViewController.h"
#import "DockFlagship+Addons.h"
#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipsViewController.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUpgradesViewController.h"
#import "DockUtilsMobile.h"

@interface DockEquippedShipController ()
@property (strong, nonatomic) NSArray* upgradeBuckets;
@end

@implementation DockEquippedShipController

-(void)viewDidLoad
{
    [super viewDidLoad];
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

-(void)viewWillAppear:(BOOL)animated
{
    [self createBuckets];
    [super viewWillAppear: animated];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    int sections = (int)_upgradeBuckets.count + 1;
    if ([_equippedShip.squad.resource isFlagship]) {
        sections += 1;
    }
    return sections;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Ship";
    }
    
    if ([_equippedShip.squad.resource isFlagship]) {
        section -= 1;
    }
    
    if (section == 0) {
        return @"Flagship";
    }

    NSInteger groupIndex = section - 1;
    NSArray* group = _upgradeBuckets[groupIndex];
    DockEquippedUpgrade* equippedUpgrade = group.firstObject;
    DockUpgrade* upgrade = equippedUpgrade.upgrade;
    return upgrade.upType;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }

    if ([_equippedShip.squad.resource isFlagship]) {
        section -= 1;
    }
    
    if (section == 0) {
        return 1;
    }
    
    NSInteger groupIndex = section - 1;
    NSArray* group = _upgradeBuckets[groupIndex];
    return group.count;
}

-(DockEquippedUpgrade*)upgradeAtPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger groupIndex = section - 1;

    if ([_equippedShip.squad.resource isFlagship]) {
        groupIndex -= 1;
    }

    if (groupIndex >= _upgradeBuckets.count) {
        return nil;
    }

    NSArray* group = _upgradeBuckets[groupIndex];
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

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];

    if (section == 0) {
        UITableViewCell* shipCell = [tableView dequeueReusableCellWithIdentifier: @"ship" forIndexPath: indexPath];
        shipCell.textLabel.text = _equippedShip.plainDescription;
        shipCell.detailTextLabel.text = [NSString stringWithFormat: @"%d (%d)", [_equippedShip cost], [_equippedShip baseCost]];
        return shipCell;
    }
    
    if ([_equippedShip.squad.resource isFlagship]) {
        section -= 1;
    }

    if (section == 0) {
        UITableViewCell* shipCell = [tableView dequeueReusableCellWithIdentifier: @"flagship" forIndexPath: indexPath];
        DockFlagship* flagship = _equippedShip.flagship;
        NSString* name = @"None";
        if (flagship != nil) {
            name = flagship.name;
        }
        shipCell.textLabel.text = name;
        return shipCell;
    }

    static NSString* CellIdentifier = @"upgrade";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    DockEquippedUpgrade* equippedUpgrade = [self upgradeAtPath: indexPath];
    DockUpgrade* upgrade = equippedUpgrade.upgrade;
    cell.textLabel.text = [upgrade title];

    if ([upgrade isPlaceholder]) {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        int baseCost = [[upgrade cost] intValue];
        int equippedCost = [equippedUpgrade cost];

        if (equippedCost == baseCost) {
            cell.detailTextLabel.text = [[upgrade cost] stringValue];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%d (%@)", [equippedUpgrade cost], [upgrade cost]];
        }
    }

    return cell;
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];

    if ([_equippedShip.squad.resource isFlagship]) {
        section -= 1;
    }

    return section > 0;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
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

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* sequeIdentifier = [segue identifier];
    id destination = [segue destinationViewController];

    if ([sequeIdentifier isEqualToString: @"PickUpgrade"]) {
        DockEquippedUpgrade* oneToReplace = [self selectedUpgrade];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = _equippedShip.managedObjectContext;
        controller.upType = [[[self selectedUpgrade] upgrade] upType];
        controller.showAdmirals = (_equippedShip.admiralCount > 0);
        id onPick = ^(DockUpgrade* upgrade, BOOL override, int overrideCost) {
            DockEquippedUpgrade* localOneToReplace = oneToReplace;
            if (![localOneToReplace.upgrade.upType isEqualToString: upgrade.upType]) {
                localOneToReplace = nil;
            }
            [self addUpgrade: upgrade replacing: localOneToReplace override: override overriddenCost: overrideCost];
        };
        [controller targetSquad: _equippedShip.squad ship: _equippedShip upgrade: oneToReplace onPicked: onPick];
    } else if ([sequeIdentifier isEqualToString: @"PickFlagship"]) {
        DockFlagshipsViewController* flagshipsViewController = (DockFlagshipsViewController*)destination;
        flagshipsViewController.managedObjectContext = [_equippedShip managedObjectContext];
        [flagshipsViewController targetSquad: _equippedShip.squad ship: _equippedShip.ship onPicked: ^(DockFlagship* theFlagship) { [self changeFlagship: theFlagship];
         }

        ];
    } else if ([sequeIdentifier isEqualToString: @"PickShip"]) {
        DockShipsViewController* shipsViewController = (DockShipsViewController*)destination;
        shipsViewController.managedObjectContext = [_equippedShip managedObjectContext];
        [shipsViewController targetSquad: _equippedShip.squad ship: _equippedShip.ship onPicked: ^(DockShip* theShip) { [self changeShip: theShip];
         }

        ];
    }
}

-(void)addUpgrade:(DockUpgrade*)upgrade replacing:(DockEquippedUpgrade*)oneToReplace override:(BOOL)override overriddenCost:(int)overriddenCost
{
    if (upgrade != oneToReplace.upgrade || override != [oneToReplace.overridden boolValue] || overriddenCost != [oneToReplace.overriddenCost intValue]) {
        [_equippedShip removeUpgrade: oneToReplace];
        DockEquippedUpgrade* eu = [_equippedShip addUpgrade: upgrade maybeReplace: nil establishPlaceholders: YES];
        if (override) {
            [eu overrideWithCost: overriddenCost];
        }
        NSError* error;

        if (!saveItem(_equippedShip, &error)) {
            presentError(error);
        }

        [self createBuckets];
        [self.tableView reloadData];
    }

    [self.navigationController popViewControllerAnimated: YES];
}

-(void)changeShip:(DockShip*)newShip
{
    if (_equippedShip.ship != newShip) {
        [_equippedShip changeShip: newShip];
        NSError* error;

        if (!saveItem(_equippedShip, &error)) {
            presentError(error);
        }

        [self createBuckets];
        [self.tableView reloadData];
    }

    [self.navigationController popViewControllerAnimated: YES];
}

-(void)changeFlagship:(DockFlagship*)newFlagship
{
    if (newFlagship == nil) {
        [_equippedShip removeFlagship];
    } else {
        [_equippedShip becomeFlagship: newFlagship];
    }
    NSError* error;

    if (!saveItem(_equippedShip, &error)) {
        presentError(error);
    }

    [self createBuckets];
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)enterEditMode:(id)sender
{
    UIBarButtonItem* editButton = sender;
    if ([self.tableView isEditing]) {
        editButton.style = UIBarButtonItemStylePlain;
        editButton.title = @"Edit";
        [self.tableView setEditing: NO animated:YES];
    } else {
        editButton.style = UIBarButtonItemStyleDone;
        editButton.title = @"Done";
        [self.tableView setEditing:YES animated:YES];
    }
}


@end
