#import "DockAdmiralTabController.h"

#import "DockAdmiral+Addons.h"
#import "DockAppDelegate.h"
#import "DockEquippedShip+Addons.h"
#import "DockSquad+Addons.h"

@implementation DockAdmiralTabController

# pragma mark - Table selection

-(NSString*)notificationName
{
    return kCurrentAdmiralChanged;
}

#pragma mark - Filtering

-(void)addAdditionalPredicates:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    [formatParts addObject: @"(not placeholder == YES)"];
}

#pragma mark - Current ship

-(BOOL)dependsOnCurrentTargetShip
{
    return YES;
}

#pragma mark - Adding to ship

-(BOOL)canAddItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship
{
    DockAdmiral* admiral = (DockAdmiral*)item;
    NSError* error;
    return [ship.squad canAddAdmiral: admiral toShip: ship error: &error];
}

-(DockEquippedUpgrade*)addItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    NSError* error;
    DockAdmiral* admiral = (DockAdmiral*)item;
    if ([squad canAddAdmiral: admiral toShip: ship error: &error]) {
        return [squad addAdmiral: admiral toShip: ship error: nil];
    } else {
        [self explainCantUniqueUpgrade: error];
    }

    return nil;
}

#pragma mark - Showing items

-(BOOL)containsThisKind:(id)item
{
    return [item isMemberOfClass: [DockAdmiral class]];
}

@end
