#import "DockShipDetailViewController.h"

#import "DockMovesViewController.h"
#import "DockShip+Addons.h"

@interface DockShipDetailViewController ()
@property (nonatomic, assign) CGFloat labelWidth;
@end

@implementation DockShipDetailViewController

#pragma mark - Table view data source

-(void)viewDidLoad
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier: @"ability"];
    _labelWidth = self.tableView.bounds.size.width - cell.textLabel.bounds.size.width;
}

-(NSInteger)rowCount
{
    NSString* str = _ship.ability;

    if (str.length > 0) {
        return kShipDetailAbility + 1;
    }

    return kShipDetailAbility;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self rowCount];
}

-(UITableViewCell*)cellForAbility:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"ability"];
    cell.textLabel.text = @"Ability";
    cell.detailTextLabel.text = _ship.ability;
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

-(UITableViewCell*)cellForUnique:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Unique";
    NSString* value = nil;

    if ([_ship isUnique]) {
        value = @"Yes";
    } else {
        value = @"No";
    }

    cell.detailTextLabel.text = value;
    return cell;
}

-(UITableViewCell*)cellForActions:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Actions";
    NSArray* actions = [_ship actionStrings];
    cell.detailTextLabel.text = [actions componentsJoinedByString: @", "];
    return cell;
}

-(UITableViewCell*)cell:(UITableView*)tableView forKey:(NSString*)key label:(NSString*)label accessory:(UITableViewCellAccessoryType)accessory
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = label;
    id value = [_ship valueForKey: key];
    NSString* textValue = [NSString stringWithFormat: @"%@", value];
    cell.detailTextLabel.text = textValue;
    cell.accessoryType = accessory;
    return cell;
}

-(UITableViewCell*)cell:(UITableView*)tableView forKey:(NSString*)key label:(NSString*)label
{
    return [self cell: tableView forKey: key label: label accessory: UITableViewCellAccessoryNone];
}

enum {
    kShipDetailTitle,
    kShipDetailClass,
    kShipDetailFaction,
    kShipDetailCost,
    kShipDetailUnique,
    kShipDetailAttack,
    kShipDetailAgility,
    kShipDetailHull,
    kShipDetailShields,
    kShipDetailCrew,
    kShipDetailTech,
    kShipDetailWeapons,
    kShipDetailBorg,
    kShipDetailFrontArc,
    kShipDetailRearArc,
    kShipDetailActions,
    kShipDetailMoves,
    kShipDetailSet,
    kShipDetailAbility
};

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];

    switch (row) {
    case kShipDetailTitle:
        return [self cell: tableView forKey: @"title" label: @"Title"];

    case kShipDetailClass:
        return [self cell: tableView forKey: @"shipClass" label: @"Class"];

    case kShipDetailFaction:
        return [self cell: tableView forKey: @"faction" label: @"Faction"];

    case kShipDetailCost:
        return [self cell: tableView forKey: @"cost" label: @"Cost"];

    case kShipDetailUnique:
        return [self cellForUnique: tableView];

    case kShipDetailAttack:
        return [self cell: tableView forKey: @"attackString" label: @"Attack"];

    case kShipDetailAgility:
        return [self cell: tableView forKey: @"agilityString" label: @"Agility"];

    case kShipDetailHull:
        return [self cell: tableView forKey: @"hull" label: @"Hull"];

    case kShipDetailShields:
        return [self cell: tableView forKey: @"shield" label: @"Shields"];

    case kShipDetailCrew:
        return [self cell: tableView forKey: @"crew" label: @"Crew"];

    case kShipDetailTech:
        return [self cell: tableView forKey: @"tech" label: @"Tech"];

    case kShipDetailWeapons:
        return [self cell: tableView forKey: @"weapon" label: @"Weapon"];

    case kShipDetailBorg:
        return [self cell: tableView forKey: @"borgCount" label: @"Borg"];

    case kShipDetailFrontArc:
        return [self cell: tableView forKey: @"formattedFrontArc" label: @"Front Arc"];

    case kShipDetailRearArc:
        return [self cell: tableView forKey: @"formattedRearArc" label: @"Rear Arc"];

    case kShipDetailSet:
        return [self cell: tableView forKey: @"setName" label: @"Set"];

    case kShipDetailMoves:
        return [self cell: tableView forKey: @"movesSummary" label: @"Key Moves" accessory: UITableViewCellAccessoryDetailDisclosureButton];

    case kShipDetailActions:
        return [self cellForActions: tableView];
    }

    return [self cellForAbility: tableView];
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat rowHeight = tableView.rowHeight;
    NSInteger lastRowIndex = [self rowCount] - 1;
    NSInteger row = [indexPath indexAtPosition: 1];

    if (row == lastRowIndex) {
        NSString* str = _ship.ability;

        if (str.length > 0) {
            CGSize size = [str sizeWithFont: [UIFont systemFontOfSize: 14] constrainedToSize: CGSizeMake(_labelWidth - 40, 999) lineBreakMode: NSLineBreakByWordWrapping];
            return size.height + rowHeight / 2;
        }
    }

    return rowHeight;
}

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];

    if (row == kShipDetailMoves) {
        [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionMiddle];
        [self performSegueWithIdentifier: @"ShowMoves" sender: self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];

    if ([identifier isEqualToString: @"ShowMoves"]) {
        DockMovesViewController* controller = (DockMovesViewController*)destination;
        controller.ship = _ship;
    }
}

@end
