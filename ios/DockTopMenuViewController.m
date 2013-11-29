#import "DockTopMenuViewController.h"

#import "DockShipsViewController.h"
#import "DockSquadsListController.h"
#import "DockResourcesViewController.h"
#import "DockUpgradesViewController.h"
#import "DockSetsListViewController.h"

@interface DockTopMenuViewController ()

@end

@implementation DockTopMenuViewController

#pragma mark - Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"GoToShips"]) {
        id destination = [segue destinationViewController];
        DockShipsViewController *shipsViewController = (DockShipsViewController *)destination;
        shipsViewController.managedObjectContext = self.managedObjectContext;
        [shipsViewController clearTarget];
    } else if ([[segue identifier] isEqualToString:@"GoToSquads"]) {
        id destination = [segue destinationViewController];
        DockSquadsListController *controller = (DockSquadsListController *)destination;
        controller.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString:@"GoToCaptains"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController *controller = (DockUpgradesViewController *)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Captain";
    } else if ([[segue identifier] isEqualToString:@"GoToCrew"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController *controller = (DockUpgradesViewController *)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Crew";
    } else if ([[segue identifier] isEqualToString:@"GoToTalents"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController *controller = (DockUpgradesViewController *)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Talent";
    } else if ([[segue identifier] isEqualToString:@"GoToTech"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController *controller = (DockUpgradesViewController *)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Tech";
    } else if ([[segue identifier] isEqualToString:@"GoToWeapons"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController *controller = (DockUpgradesViewController *)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Weapon";
    } else if ([[segue identifier] isEqualToString:@"GoToResources"]) {
        id destination = [segue destinationViewController];
        DockResourcesViewController *controller = (DockResourcesViewController *)destination;
        controller.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString:@"GoToSets"]) {
        id destination = [segue destinationViewController];
        DockSetsListViewController *controller = (DockSetsListViewController *)destination;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

@end
