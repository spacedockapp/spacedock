#import "DockFleetCaptainTabController.h"

#import "DockEquippedShip+Addons.h"
#import "DockFleetCaptain.h"
#import "DockSquad+Addons.h"

@implementation DockFleetCaptainTabController

# pragma mark - Table selection

-(NSString*)notificationName
{
    return kCurrentFleetCaptainChanged;
}

#pragma mark - Filtering

-(void)addAdditionalPredicatesForFaction:(NSString*)factionName formatParts:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    if (self.dependsOnFaction && factionName != nil) {
        [formatParts addObject: @"(faction in %@)"];
        [arguments addObject: @[factionName, @"Independent"]];
    }
}

#pragma mark - Current Ship

-(BOOL)dependsOnCurrentTargetShip
{
    return YES;
}

#pragma mark - Adding to ship

-(BOOL)canAddItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship
{
    NSError* error;
    DockFleetCaptain* fleetCaptain = (DockFleetCaptain*)item;
    return [ship.squad canAddFleetCaptain: fleetCaptain toShip: ship error: &error];
}

-(DockEquippedUpgrade*)addItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    NSError* error;
    DockFleetCaptain* fleetCaptain = (DockFleetCaptain*)item;
    if ([squad canAddFleetCaptain: fleetCaptain toShip: ship error: &error]) {
        return [squad addFleetCaptain: fleetCaptain toShip: ship error: nil];
    } else {
        [self explainCantUniqueUpgrade: error];
    }

    return nil;
}

#pragma mark - Showing items

-(BOOL)containsThisKind:(id)item
{
    return [item isMemberOfClass: [DockFleetCaptain class]];
}

@end
