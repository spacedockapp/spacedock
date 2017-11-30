#import "DockEquippedShipController.h"

#import "DockConstants.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagshipsViewController.h"
#import "DockFlagship+Addons.h"
#import "DockExtrasTableViewCell.h"
#import "DockResource+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipsViewController.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUpgradesViewController.h"
#import "DockUtilsMobile.h"

#import "DockRowHandler.h"
#import "DockSectionHandler.h"

#import "DockAdmiralRowHandler.h"
#import "DockFlagshipRowHandler.h"
#import "DockFleetCaptainRowHandler.h"
#import "DockOfficerRowHandler.h"
#import "DockShipRowHandler.h"
#import "DockUpgradeRowHandler.h"
#import "DockResourceUpgradeRowHandler.h"

#pragma mark - DockEquippedShipController

@interface DockEquippedShipController ()
@property (strong, nonatomic) NSArray* sections;
@property (nonatomic, assign) BOOL mark50spShip;
@end

@implementation DockEquippedShipController

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _mark50spShip = [defaults boolForKey: @"mark50spShip"];
}

-(void)createSectionAndRowHandlers
{
    NSString* flagshipTitle = @"Flagship";

    NSMutableSet* sectionTitles = [[NSMutableSet alloc] initWithCapacity: 0];
    NSMutableArray* sections = [NSMutableArray arrayWithCapacity: 0];

    DockSectionHandler* currentSection = [[DockSectionHandler alloc] init];
    currentSection.title = @"Ship";
    DockShipRowHandler* shipRowHandler = [[DockShipRowHandler alloc] init];
    shipRowHandler.controller = self;
    shipRowHandler.equippedShip = _equippedShip;
    shipRowHandler.mark50spShip = _mark50spShip;
    [currentSection addRowHandler: shipRowHandler];
    [sections addObject: currentSection];

    DockFlagship* fs = _equippedShip.flagship;
    if (fs != nil) {
        DockSectionHandler* currentSection = [[DockSectionHandler alloc] init];
        currentSection.title = flagshipTitle;
        DockFlagshipRowHandler* fsRowHandler = [[DockFlagshipRowHandler alloc] init];
        fsRowHandler.controller = self;
        fsRowHandler.equippedShip = _equippedShip;
        [currentSection addRowHandler: fsRowHandler];
        [sections addObject: currentSection];
        [sectionTitles addObject: flagshipTitle];
    }

    currentSection = [[DockSectionHandler alloc] init];
    NSArray* sortedUpgrades = _equippedShip.sortedUpgrades;
    NSString* lastUpgradeType;
    if (sortedUpgrades.count > 0) {
        DockEquippedUpgrade* firstUpgrade = sortedUpgrades.firstObject;
        lastUpgradeType = firstUpgrade.upgrade.upType;
    } else {
        lastUpgradeType = @"";
    }
    currentSection.title = lastUpgradeType;
    [sectionTitles addObject: lastUpgradeType];
    int currentUpgradeCount = 0;

    for (DockEquippedUpgrade* equippedUpgrade in _equippedShip.sortedUpgrades) {
        DockUpgrade* upgrade = equippedUpgrade.upgrade;

        if (![lastUpgradeType isEqualToString: upgrade.upType]) {
            if ([lastUpgradeType isEqualToString: kOfficerUpgradeType]) {
                int officerLimit = [_equippedShip officerLimit];
                if (currentUpgradeCount < officerLimit) {
                    DockOfficerRowHandler* officerHandler = [[DockOfficerRowHandler alloc] init];
                    officerHandler.controller = self;
                    [currentSection addRowHandler: officerHandler];
                }
            }
            if (currentSection.rowHandlerCount > 0) {
                [sections addObject: currentSection];
            }

            currentSection = [[DockSectionHandler alloc] init];
            currentUpgradeCount = 0;
            lastUpgradeType = [upgrade upType];
            currentSection.title = lastUpgradeType;
            [sectionTitles addObject: lastUpgradeType];
        }

        DockUpgradeRowHandler* handler = [[DockUpgradeRowHandler alloc] init];
        handler.controller = self;
        handler.equippedUpgrade = equippedUpgrade;
        [currentSection addRowHandler: handler];
        currentUpgradeCount+=1;
    }

    if (currentSection.rowHandlerCount > 0) {
        [sections addObject: currentSection];
    }

    DockSectionHandler* extrasSection = [[DockSectionHandler alloc] init];
    extrasSection.title = @"Extras";

    if ([_equippedShip.squad.resource isFlagship] && ![sectionTitles containsObject: @"Flagship"]) {
        DockFlagshipRowHandler* handler = [[DockFlagshipRowHandler alloc] init];
        handler.controller = self;
        handler.equippedShip = _equippedShip;
        [extrasSection addRowHandler: handler];
    } else if ([_equippedShip.squad.resource isFleetCaptain] && ![sectionTitles containsObject: kFleetCaptainUpgradeType]) {
        DockFleetCaptainRowHandler* handler = [[DockFleetCaptainRowHandler alloc] init];
        handler.equippedShip = _equippedShip;
        handler.controller = self;
        [extrasSection addRowHandler: handler];
    }

    if (![sectionTitles containsObject: kAdmiralUpgradeType] && !_equippedShip.isResourceSideboard && _equippedShip.captainCount > 0 && !_equippedShip.ship.isShuttle) {
        DockAdmiralRowHandler* admiralHandler = [[DockAdmiralRowHandler alloc] init];
        admiralHandler.equippedShip = _equippedShip;
        admiralHandler.controller = self;
        [extrasSection addRowHandler: admiralHandler];
    }

    if ([_equippedShip.squad.resource isOfficerCards] && ![sectionTitles containsObject: kOfficerUpgradeType]) {
        DockOfficerRowHandler* officerHandler = [[DockOfficerRowHandler alloc] init];
        officerHandler.controller = self;
        [extrasSection addRowHandler: officerHandler];
    }
    
    if (![sectionTitles containsObject: @"Resource"] && [_equippedShip.squad.resource.externalId isEqualToString:@"captains_chair_72936r"]) {

        DockResourceUpgradeRowHandler* resourceHandler = [[DockResourceUpgradeRowHandler alloc] init];
        resourceHandler.equippedShip = _equippedShip;
        resourceHandler.controller = self;

        if ([_equippedShip.squad.resource.externalId isEqualToString:@"captains_chair_72936r"] && [_equippedShip.squad containsUniqueUpgradeWithName:@"Captain's Chair"] == nil) {
            
            resourceHandler.controller = self;
            [extrasSection addRowHandler:resourceHandler];
        }
    }
    if (![sectionTitles containsObject: @"Resource"] && [_equippedShip.squad.resource.externalId isEqualToString:@"front-line_retrofit_72941r"]) {
        
        DockResourceUpgradeRowHandler* resourceHandler = [[DockResourceUpgradeRowHandler alloc] init];
        resourceHandler.equippedShip = _equippedShip;
        resourceHandler.controller = self;
        
        if ([_equippedShip.squad.resource.externalId isEqualToString:@"front-line_retrofit_72941r"] && [_equippedShip.squad containsUniqueUpgradeWithName:@"Front-Line Retrofit"] == nil) {
            
            resourceHandler.controller = self;
            [extrasSection addRowHandler:resourceHandler];
        }
    }
    
    if (extrasSection.rowHandlerCount > 0) {
        [sections addObject: extrasSection];
    }

    _sections = [NSArray arrayWithArray: sections];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.equippedShip establishPlaceholders];
    [self createSectionAndRowHandlers];
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
    return _sections.count;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    assert(section >= 0 && section < _sections.count);
    DockSectionHandler* handler = _sections[section];
    return handler.title;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    assert(section >= 0 && section < _sections.count);
    DockSectionHandler* handler = _sections[section];
    return handler.rowHandlerCount;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    assert(section >= 0 && section < _sections.count);
    DockSectionHandler* handler = _sections[section];
    return [handler tableView:tableView cellForRowAtIndexPath: indexPath];
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    assert(section >= 0 && section < _sections.count);
    DockSectionHandler* handler = _sections[section];
    return [handler tableView:tableView shouldHighlightRowAtIndexPath: indexPath];
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    assert(section >= 0 && section < _sections.count);
    DockSectionHandler* handler = _sections[section];
    [handler tableView:tableView didHighlightRowAtIndexPath: indexPath];
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    assert(section >= 0 && section < _sections.count);
    DockSectionHandler* handler = _sections[section];
    return [handler tableView:tableView canEditRowAtIndexPath: indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    assert(section >= 0 && section < _sections.count);
    DockSectionHandler* handler = _sections[section];
    return [handler tableView:tableView heightForRowAtIndexPath: indexPath];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger section = [indexPath indexAtPosition: 0];
        assert(section > 0 && section < _sections.count);
        DockSectionHandler* handler = _sections[section];
        [handler tableView:tableView commitEditingStyle: editingStyle forRowAtIndexPath: indexPath];

        NSError* error;

        if (!saveItem(_equippedShip, &error)) {
            presentError(error);
        }

        [self createSectionAndRowHandlers];
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
        DockEquippedUpgrade* oneToReplace = sender;
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = _equippedShip.managedObjectContext;
        controller.upType = [[oneToReplace upgrade] upType];
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
        id handler = ^(DockFlagship* theFlagship) { [self changeFlagship: theFlagship]; };
        [flagshipsViewController targetSquad: _equippedShip.squad ship: _equippedShip.ship onPicked: handler];
    } else if ([sequeIdentifier isEqualToString: @"PickFleetCaptain"]) {
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = _equippedShip.managedObjectContext;
        controller.upType = kFleetCaptainUpgradeType;
        id onPick = ^(DockUpgrade* upgrade, BOOL override, int overrideCost) {
            [self changeFleetCaptain: upgrade];
        };
        [controller targetSquad: _equippedShip.squad ship: _equippedShip upgrade: nil onPicked: onPick];
    } else if ([sequeIdentifier isEqualToString: @"PickOfficer"]) {
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = _equippedShip.managedObjectContext;
        controller.upType = kOfficerUpgradeType;
        id onPick = ^(DockUpgrade* upgrade, BOOL override, int overrideCost) {
            [self addUpgrade: upgrade replacing: nil override: override overriddenCost: overrideCost];
        };
        [controller targetSquad: _equippedShip.squad ship: _equippedShip upgrade: nil onPicked: onPick];
    } else if ([sequeIdentifier isEqualToString: @"PickAdmiral"]) {
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = _equippedShip.managedObjectContext;
        controller.upType = kAdmiralUpgradeType;
        id onPick = ^(DockUpgrade* upgrade, BOOL override, int overrideCost) {
            [self changeAdmiral: upgrade];
        };
        [controller targetSquad: _equippedShip.squad ship: _equippedShip upgrade: nil onPicked: onPick];
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

        [self createSectionAndRowHandlers];
        [self.tableView reloadData];
    }

    [self.navigationController popViewControllerAnimated: YES];
}

-(void)changeFleetCaptain:(DockUpgrade*)upgrade
{
    if (_equippedShip.equippedFleetCaptain.upgrade != upgrade) {
        DockFleetCaptain* newFleetCaptain = (DockFleetCaptain*)upgrade;
        DockSquad* squad = _equippedShip.squad;
        NSError* error;

        if (![squad addFleetCaptain: newFleetCaptain toShip: _equippedShip error: &error]) {
            presentError(error);
        } else {
            if (!saveItem(_equippedShip, &error)) {
                presentError(error);
            }

            [self createSectionAndRowHandlers];
            [self.tableView reloadData];
        }
    }

    [self.navigationController popViewControllerAnimated: YES];
}

-(void)changeAdmiral:(DockUpgrade*)upgrade
{
    if (_equippedShip.equippedAdmiral.upgrade != upgrade) {
        DockAdmiral* newAdmiral = (DockAdmiral*)upgrade;
        DockSquad* squad = _equippedShip.squad;
        NSError* error;

        if (![squad addAdmiral: newAdmiral toShip: _equippedShip error: &error]) {
            presentError(error);
        } else {
            if (!saveItem(_equippedShip, &error)) {
                presentError(error);
            }

            [self createSectionAndRowHandlers];
            [self.tableView reloadData];
        }
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

        [self createSectionAndRowHandlers];
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

    [self createSectionAndRowHandlers];
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
