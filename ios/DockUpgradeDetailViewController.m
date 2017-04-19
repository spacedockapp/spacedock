#import "DockUpgradeDetailViewController.h"

#import "DockAdmiral+Addons.h"
#import "DockCaptain+Addons.h"
#import "DockFleetCaptain+Addons.h"
#import "DockSetItem+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"
#import "DockWeapon+Addons.h"

@interface DockUpgradeDetailViewController ()
@property (nonatomic, assign) CGFloat labelWidth;
@end

@implementation DockUpgradeDetailViewController

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
        rows = 9;
    }

    if ([_upgrade isFleetCaptain]) {
        rows = 11;
    }

    if ([_upgrade isAdmiral]) {
        rows = 8;
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
    cell.detailTextLabel.text = combinedFactionString(_upgrade);
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

-(UITableViewCell*)cellForSkillModifier:(UITableView*)tableView
{
    DockAdmiral* admiral = (DockAdmiral*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Skill Modifier";
    cell.detailTextLabel.text = [NSString stringWithFormat: @"+%@", admiral.skillModifier];
    return cell;
}

-(UITableViewCell*)cellForCaptainSkillBonus:(UITableView*)tableView
{
    DockFleetCaptain* fc = (DockFleetCaptain*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Skill Modifier";
    cell.detailTextLabel.text = [NSString stringWithFormat: @"+%@", fc.captainSkillBonus];
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

-(UITableViewCell*)cellForCrewAdd:(UITableView*)tableView
{
    DockFleetCaptain* fc = (DockFleetCaptain*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Crew";
    cell.detailTextLabel.text = [fc.crewAdd stringValue];
    return cell;
}

-(UITableViewCell*)cellForWeaponAdd:(UITableView*)tableView
{
    DockFleetCaptain* fc = (DockFleetCaptain*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Weapon";
    cell.detailTextLabel.text = [fc.weaponAdd stringValue];
    return cell;
}

-(UITableViewCell*)cellForTechAdd:(UITableView*)tableView
{
    DockFleetCaptain* fc = (DockFleetCaptain*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Tech";
    cell.detailTextLabel.text = [fc.techAdd stringValue];
    return cell;
}

-(UITableViewCell*)cellForTalentAdd:(UITableView*)tableView
{
    DockFleetCaptain* fc = (DockFleetCaptain*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Talent";
    cell.detailTextLabel.text = [fc.talentAdd stringValue];
    return cell;
}

-(UITableViewCell*)cellForAdmiralTalent:(UITableView*)tableView
{
    DockAdmiral* admiral = (DockAdmiral*)_upgrade;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"default"];
    cell.textLabel.text = @"Adm. Talent";
    cell.detailTextLabel.text = [admiral.admiralTalent stringValue];
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
    } else if ([_upgrade isMirrorUniverseUnique]) {
        value = @"MU";
    } else {
        value = @"No";
    }

    cell.detailTextLabel.text = value;
    return cell;
}

-(UITableViewCell*)cellForSet:(UITableView*)tableView
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"ability"];
    cell.textLabel.text = @"Set";
    if ([_upgrade.setName rangeOfString:@","].location != NSNotFound) {
        cell.textLabel.text = @"Sets";
    }
    cell.detailTextLabel.text = _upgrade.setName;
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];

    if ([_upgrade isAdmiral]) {
        switch (row) {
        case 0:
            return [self cellForTitle: tableView];

        case 1:
            return [self cellForFaction: tableView];

        case 2:
            return [self cellForSkill: tableView];

        case 3:
            return [self cellForSkillModifier: tableView];

        case 4:
            return [self cellForCost: tableView];

        case 5:
            return [self cellForAdmiralTalent: tableView];

        case 6:
            return [self cellForSet: tableView];
        }
        return [self cellForAbility: tableView];
    } else if ([_upgrade isFleetCaptain]) {
        switch (row) {
        case 0:
            return [self cellForTitle: tableView];

        case 1:
            return [self cellForFaction: tableView];

        case 2:
            return [self cellForType: tableView];

        case 3:
            return [self cellForCaptainSkillBonus: tableView];

        case 4:
            return [self cellForCost: tableView];

        case 5:
            return [self cellForCrewAdd: tableView];

        case 6:
            return [self cellForTalentAdd: tableView];

        case 7:
            return [self cellForTechAdd: tableView];

        case 8:
            return [self cellForWeaponAdd: tableView];

        case 9:
            return [self cellForSet: tableView];
        }
        return [self cellForAbility: tableView];
    } else if ([_upgrade isCaptain]) {
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
    NSInteger setRowIndex = 5;
    if ([_upgrade isAdmiral]) {
        setRowIndex = 6;
    } else if ([_upgrade isFleetCaptain]) {
        setRowIndex = 9;
    } else if ([_upgrade isCaptain]) {
        setRowIndex = 7;
    } else if ([_upgrade isWeapon]) {
        setRowIndex = 7;
    }
    
    if (row == lastRowIndex) {
        NSString* str = _upgrade.ability;
        
        if (str.length > 0) {
            CGSize size = [str boundingRectWithSize:CGSizeMake(_labelWidth - 5, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 14]} context:nil].size;
            CGFloat rowHeight = size.height + 20;
            return rowHeight;
        }
    }
    
    if (row == setRowIndex) {
        NSString* str = _upgrade.setName;
        
        if (str.length > 0) {
            CGSize size = [str boundingRectWithSize:CGSizeMake(_labelWidth - 5, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 14]} context:nil].size;            CGFloat rowHeight = size.height + 20;
            return rowHeight;
        }
    }

    return tableView.rowHeight;
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

@end
