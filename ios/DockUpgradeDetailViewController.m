#import "DockUpgradeDetailViewController.h"

#import "DockCaptain+Addons.h"
#import "DockSetItem+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockWeapon+Addons.h"

@interface DockUpgradeDetailViewController ()
@property (nonatomic, assign) CGFloat labelWidth;
@end

@implementation DockUpgradeDetailViewController

-(void)viewDidLoad
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier: @"ability"];
    _labelWidth = self.tableView.bounds.size.width - cell.textLabel.bounds.size.width;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)rowCount
{
    NSInteger rows = 7;

    if ([_upgrade isWeapon]) {
        rows += 2;
    }

    if ([_upgrade isCaptain]) {
        rows += 2;
    }

    if (_upgrade.ability.length == 0) {
        rows -= 1;
    }

    return rows;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self rowCount];
}

-(UITableViewCell*)cellForAbility:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"ability"];
    cell.textLabel.text = @"Ability";
    cell.detailTextLabel.text = _upgrade.ability;
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

-(UITableViewCell*)cellForTitle:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Title";
    cell.detailTextLabel.text = _upgrade.title;
    return cell;
}

-(UITableViewCell*)cellForFaction:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Faction";
    cell.detailTextLabel.text = _upgrade.faction;
    return cell;
}

-(UITableViewCell*)cellForType:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Type";
    cell.detailTextLabel.text = _upgrade.upType;
    return cell;
}

-(UITableViewCell*)cellForCost:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Cost";
    cell.detailTextLabel.text = [_upgrade.cost stringValue];
    return cell;
}

-(UITableViewCell*)cellForSkill:(UITableView*)tableView
{
    DockCaptain* captain = (DockCaptain*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Skill";
    cell.detailTextLabel.text = [captain.skill stringValue];
    return cell;
}

-(UITableViewCell*)cellForTalent:(UITableView*)tableView
{
    DockCaptain* captain = (DockCaptain*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Talent";
    cell.detailTextLabel.text = [captain.talent stringValue];
    return cell;
}

-(UITableViewCell*)cellForAttack:(UITableView*)tableView
{
    DockWeapon* weapon = (DockWeapon*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Attack";
    cell.detailTextLabel.text = [weapon.attack stringValue];
    return cell;
}

-(UITableViewCell*)cellForRange:(UITableView*)tableView
{
    DockWeapon* weapon = (DockWeapon*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Range";
    cell.detailTextLabel.text = weapon.range;
    return cell;
}

-(UITableViewCell*)cellForUnique:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Unique";
    NSString* value = nil;

    if ([_upgrade isUnique]) {
        value = @"Yes";
    } else {
        value = @"No";
    }

    cell.detailTextLabel.text = value;
    return cell;
}

-(UITableViewCell*)cellForSet:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Set";
    cell.detailTextLabel.text = _upgrade.setName;
    return cell;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];

    if ([_upgrade isCaptain]) {
        switch (row) {
        case 0:
            return [self cellForTitle: tableView];

        case 1:
            return [self cellForFaction: tableView];

        case 2:
            return [self cellForType: tableView];

        case 3:
            return [self cellForSkill: tableView];

        case 4:
            return [self cellForCost: tableView];

        case 5:
            return [self cellForUnique: tableView];

        case 6:
            return [self cellForTalent: tableView];

        case 7:
            return [self cellForSet: tableView];
        }
        return [self cellForAbility: tableView];
    } else if ([_upgrade isWeapon]) {
        switch (row) {
        case 0:
            return [self cellForTitle: tableView];

        case 1:
            return [self cellForFaction: tableView];

        case 2:
            return [self cellForType: tableView];

        case 3:
            return [self cellForCost: tableView];

        case 4:
            return [self cellForUnique: tableView];

        case 5:
            return [self cellForAttack: tableView];

        case 6:
            return [self cellForRange: tableView];

        case 7:
            return [self cellForSet: tableView];
        }
        return [self cellForAbility: tableView];
    } else {
        switch (row) {
        case 0:
            return [self cellForTitle: tableView];

        case 1:
            return [self cellForFaction: tableView];

        case 2:
            return [self cellForType: tableView];

        case 3:
            return [self cellForCost: tableView];

        case 4:
            return [self cellForUnique: tableView];

        case 5:
            return [self cellForSet: tableView];
        }
    }

    return [self cellForAbility: tableView];
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger lastRowIndex = [self rowCount] - 1;
    NSInteger row = [indexPath indexAtPosition: 1];

    if (row == lastRowIndex) {
        NSString* str = _upgrade.ability;

        if (str.length > 0) {
            CGSize size = [str sizeWithFont: [UIFont systemFontOfSize: 14] constrainedToSize: CGSizeMake(_labelWidth - 40, 999) lineBreakMode: NSLineBreakByWordWrapping];
            CGFloat rowHeight = size.height + 20;
            return rowHeight;
        }
    }

    return tableView.rowHeight;
}

@end
