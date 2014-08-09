#import "DockTopMenuViewController.h"

#import "DockConstants.h"
#import "DockResourcesViewController.h"
#import "DockSetsListViewController.h"
#import "DockShipsViewController.h"
#import "DockSquadsListController.h"
#import "DockUpgradesViewController.h"
#import "DockFlagshipsViewController.h"
#import "DockReferenceViewController.h"

@interface DockTopMenuViewController ()
@property (strong, nonatomic) UIAlertView* loadingAlert;
@end

@implementation DockTopMenuViewController

#pragma mark - Appearing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    if (_managedObjectContext == nil) {
        _loadingAlert = [[UIAlertView alloc] initWithTitle:@"Loading Data" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [_loadingAlert show];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(_loadingAlert.bounds.size.width / 2, _loadingAlert.bounds.size.height - 50);
        [indicator startAnimating];
        [_loadingAlert addSubview:indicator];
    }
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [_loadingAlert dismissWithClickedButtonIndex: 0 animated: YES];
    _loadingAlert = nil;
}

#pragma mark - Segue management

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return _managedObjectContext != nil;
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString: @"GoToShips"]) {
        id destination = [segue destinationViewController];
        DockShipsViewController* shipsViewController = (DockShipsViewController*)destination;
        shipsViewController.managedObjectContext = self.managedObjectContext;
        [shipsViewController clearTarget];
    } else if ([[segue identifier] isEqualToString: @"GoToSquads"]) {
        id destination = [segue destinationViewController];
        DockSquadsListController* controller = (DockSquadsListController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.targetSquad = _targetSquad;
    } else if ([[segue identifier] isEqualToString: @"GoToCaptains"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Captain";
        controller.upgradeTypeName = @"Captains";
    } else if ([[segue identifier] isEqualToString: @"GoToCrew"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Crew";
        controller.upgradeTypeName = @"Crew";
    } else if ([[segue identifier] isEqualToString: @"GoToTalents"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Talent";
        controller.upgradeTypeName = @"Talents";
    } else if ([[segue identifier] isEqualToString: @"GoToBorg"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Borg";
        controller.upgradeTypeName = @"Borg Upgrades";
    } else if ([[segue identifier] isEqualToString: @"GoToTech"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Tech";
        controller.upgradeTypeName = @"Tech";
    } else if ([[segue identifier] isEqualToString: @"GoToWeapons"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Weapon";
        controller.upgradeTypeName = @"Weapons";
    } else if ([[segue identifier] isEqualToString: @"GoToAdmirals"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = kAdmiralUpgradeType;
        controller.upgradeTypeName = @"Admirals";
    } else if ([[segue identifier] isEqualToString: @"GoToFleetCaptains"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = kFleetCaptainUpgradeType;
        controller.upgradeTypeName = @"Fleet Captains";
    } else if ([[segue identifier] isEqualToString: @"GoToResources"]) {
        id destination = [segue destinationViewController];
        DockResourcesViewController* controller = (DockResourcesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString: @"GoToFlagships"]) {
        id destination = [segue destinationViewController];
        DockFlagshipsViewController* controller = (DockFlagshipsViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString: @"GoToSets"]) {
        id destination = [segue destinationViewController];
        DockSetsListViewController* controller = (DockSetsListViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString: @"GoToReference"]) {
        id destination = [segue destinationViewController];
        DockReferenceViewController* controller = (DockReferenceViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
    }
    _targetSquad = nil;
}

-(void)showSquad:(DockSquad*)squad
{
    _targetSquad = squad;
    [self performSegueWithIdentifier: @"GoToSquads" sender: self];
}

@end
