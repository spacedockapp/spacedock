#import "DockShipDetailViewController.h"

#import "DockMovesViewController.h"
#import "DockShip+Addons.h"
#import "DockSetItem+Addons.h"

@interface DockShipDetailViewController ()
@property (nonatomic, assign) CGFloat labelWidth;
@end

@implementation DockShipDetailViewController

#pragma mark - Table view data source

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self recalculateWidth];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self recalculateWidth];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self recalculateWidth];
}

-(void)recalculateWidth
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

-(UITableViewCell*)cellForSet:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"ability"];
    cell.textLabel.text = @"Set";
    if ([_ship.setName rangeOfString:@","].location != NSNotFound) {
        cell.textLabel.text = @"Sets";
    }
    cell.detailTextLabel.text = _ship.setName;
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
    } else if ([_ship isMirrorUniverseUnique]) {
        value = @"MU";
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

-(UITableViewCell*)cellFor360Arc:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"360º Arc";
    NSString* value = nil;

    if ([[_ship has360Arc] boolValue]) {
        value = @"Yes";
    } else {
        value = @"No";
    }

    cell.detailTextLabel.text = value;
    return cell;
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
    kShipDetailSquadronUpgrade,
    kShipDetailFrontArc,
    kShipDetailRearArc,
    kShipDetail360Arc,
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
        return [self cell: tableView forKey: @"combinedFactions" label: @"Faction"];

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

    case kShipDetailSquadronUpgrade:
         return [self cell: tableView forKey: @"squadronUpgradeCount" label: @"Squadron"];

    case kShipDetailFrontArc:
        return [self cell: tableView forKey: @"formattedFrontArc" label: @"Front Arc"];

    case kShipDetailRearArc:
        return [self cell: tableView forKey: @"formattedRearArc" label: @"Rear Arc"];

    case kShipDetail360Arc:
        return [self cellFor360Arc: tableView];

    case kShipDetailSet:
        return [self cellForSet:tableView];

    case kShipDetailMoves:
        return [self cell: tableView forKey: @"movesSummary" label: @"Key Moves" accessory: UITableViewCellAccessoryDetailButton];

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
    NSInteger setRowIndex = 19;
    
    if (row == lastRowIndex) {
        NSString* str = _ship.ability;

        if (str.length > 0) {
            CGSize size = [str boundingRectWithSize:CGSizeMake(_labelWidth - 5, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 14]} context:nil].size;
            CGFloat rowHeight = size.height + 20;
            return rowHeight;
        }

    }

    if (row == setRowIndex) {
        NSString* str = _ship.setName;
        
        if (str.length > 0) {
            CGSize size = [str boundingRectWithSize:CGSizeMake(_labelWidth - 5, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 14]} context:nil].size;
            CGFloat rowHeight = size.height + 20;
            return rowHeight;
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

-(void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.detailTextLabel.text && ![cell.detailTextLabel.text isEqual:@""]) {
        [gpBoard setString:cell.detailTextLabel.text];
    } else {
        [gpBoard setString:cell.textLabel.text];
    }
}


-(BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (action == @selector(copy:) && [cell.textLabel.text isEqualToString:@"Ability"]) {
        return YES;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"Ability"]) {
        return YES;
    } else {
        return NO;
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
