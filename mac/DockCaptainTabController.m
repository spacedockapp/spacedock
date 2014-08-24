#import "DockCaptainTabController.h"

#import "DockAppDelegate.h"
#import "DockCaptain+MacAddons.h"
#import "DockEquippedShip+Addons.h"
#import "DockSquad+Addons.h"

@implementation DockCaptainTabController

# pragma mark - Table selection

-(NSString*)notificationName
{
    return kCurrentCaptainChanged;
}

#pragma mark - Filtering

-(void)addAdditionalPredicates:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    [formatParts addObject: @"(not upType like 'Admiral') and (not placeholder == YES)"];
}

#pragma mark - Current ship

-(BOOL)dependsOnCurrentTargetShip
{
    return YES;
}

#pragma mark - Adding to ship

-(BOOL)canAddItem:(DockComponent*)item toShip:(DockEquippedShip*)ship
{
    DockCaptain* captain = (DockCaptain*)item;
    NSError* error;
    return [ship.squad canAddCaptain: captain toShip: ship error: &error];
}

-(DockEquippedUpgrade*)addItem:(DockComponent*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    NSError* error;
    DockCaptain* captain = (DockCaptain*)item;
    if ([squad canAddCaptain: captain toShip: ship error: &error]) {
        return [squad addCaptain: captain toShip: ship error: nil];
    } else {
        [self explainCantUniqueUpgrade: error];
    }

    return nil;
}

#pragma mark - Searching

-(BOOL)hasTitle
{
    return YES;
}

#pragma mark - Showing items

-(BOOL)containsThisKind:(id)item
{
    return [item isMemberOfClass: [DockCaptain class]];
}

@end
