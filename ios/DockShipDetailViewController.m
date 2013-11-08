#import "DockShipDetailViewController.h"

#import "DockShip+Addons.h"

@interface DockShipDetailViewController ()
@property (nonatomic, assign) CGFloat labelWidth;
@end

@implementation DockShipDetailViewController

#pragma mark - Table view data source

-(void)viewDidLoad
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"ability"];
    _labelWidth = self.tableView.bounds.size.width - cell.textLabel.bounds.size.width;
}

-(NSInteger)rowCount
{
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self rowCount];
}

-(UITableViewCell*)cellForAbility:(UITableView*)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ability"];
    cell.textLabel.text = @"Ability";
    cell.detailTextLabel.text = _ship.ability;
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

-(UITableViewCell*)cellForTitle:(UITableView*)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Title";
    cell.detailTextLabel.text = _ship.title;
    return cell;
}

-(UITableViewCell*)cellForFaction:(UITableView*)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Faction";
    cell.detailTextLabel.text = _ship.faction;
    return cell;
}

-(UITableViewCell*)cellForClass:(UITableView*)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Class";
    cell.detailTextLabel.text = _ship.shipClass;
    return cell;
}

-(UITableViewCell*)cellForCost:(UITableView*)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Cost";
    cell.detailTextLabel.text = [_ship.cost stringValue];
    return cell;
}

-(UITableViewCell*)cellForUnique:(UITableView*)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];

    switch (row) {
    case 0:
        return [self cellForTitle: tableView];
    case 1:
        return [self cellForClass: tableView];
    case 2:
        return [self cellForFaction: tableView];
    case 3:
        return [self cellForCost: tableView];
    case 4:
        return [self cellForUnique: tableView];
    }

    return [self cellForAbility: tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastRowIndex = [self rowCount] - 1;
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row == lastRowIndex) {
        NSString *str = _ship.ability;
        if (str.length > 0) {
            CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(_labelWidth-40, 999) lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat rowHeight = size.height+20;
            return rowHeight;
        }
    }
    return tableView.rowHeight;
}

@end
