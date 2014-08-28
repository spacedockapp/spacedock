#import "DockOfficerTabController.h"

#import "DockEquippedShip+Addons.h"
#import "DockOfficer.h"
#import "DockSquad+Addons.h"

@implementation DockOfficerTabController

# pragma mark - Table selection

-(NSString*)notificationName
{
    return kCurrentOfficerChanged;
}

#pragma mark - Filtering

-(void)addAdditionalPredicates:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    [formatParts addObject: @"(not placeholder == YES)"];
}

-(BOOL)dependsOnFaction
{
    return NO;
}

#pragma mark - Current ship

-(BOOL)dependsOnCurrentTargetShip
{
    return NO;
}

#pragma mark - Adding to ship

-(BOOL)canAddItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship
{
    DockOfficer* officer = (DockOfficer*)item;
    NSError* error;
    return [ship.squad canAddOfficer: officer toShip: ship error: &error];
}

-(DockEquippedUpgrade*)addItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    NSError* error;
    DockOfficer* officer = (DockOfficer*)item;
    if ([squad canAddOfficer: officer toShip: ship error: &error]) {
        return [squad addOfficer: officer toShip: ship error: nil];
    } else {
        [self explainCantUniqueUpgrade: error];
    }

    return nil;
}

#pragma mark - Showing items

-(BOOL)containsThisKind:(id)item
{
    return [item isMemberOfClass: [DockOfficer class]];
}

@end
