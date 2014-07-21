#import "DockResourceTabController.h"

#import "DockAppDelegate.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockSquad+Addons.h"

@implementation DockResourceTabController

#pragma mark - Filtering

-(BOOL)dependsOnFaction
{
    return NO;
}

#pragma mark Adding to ship

-(DockEquippedUpgrade*)addItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    DockResource* resource = (DockResource*)item;
    squad.resource = resource;
    return nil;
}

@end
