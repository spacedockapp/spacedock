#import "DockShipTabController.h"

#import "DockAppDelegate.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

#import "NSTreeController+Additions.h"

@implementation DockShipTabController

#pragma mark - Adding items

-(void)explainCantAddShip:(DockShip*)ship
{
    NSAlert* alert = [[NSAlert alloc] init];
    NSString* msg = [NSString stringWithFormat: @"Can't add %@ to the selected squadron.", ship.title];
    [alert setMessageText: msg];
    NSString* info = @"This ship is unique and one with the same name already exists in the squadron.";
    [alert setInformativeText: info];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: [self window]
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(DockEquippedUpgrade*)addItem:(DockComponent*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    DockShip* newShip = (DockShip*)item;

    if (ship.isFighterSquadron) {
        DockResource* resource = newShip.associatedResource;
        squad.resource = resource;
    } else {
        if ([newShip isUnique]) {
            DockEquippedShip* existing = [squad containsShip: newShip];

            if (existing != nil) {
                [self explainCantAddShip: newShip];
                return nil;
            }
        }

        DockEquippedShip* es = [DockEquippedShip equippedShipWithShip: newShip];
        [squad addEquippedShip: es];
        if (newShip.isFighterSquadron) {
            squad.resource = newShip.associatedResource;
        }
        [self.appDelegate selectShip: es];
    }
    return nil;
}

# pragma mark - Filtering

-(void)addAdditionalPredicatesForSearchTerm:(NSString*)searchTerm formatParts:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    [formatParts addObject: @"((title contains[cd] %@ and unique == TRUE) or (shipClass contains[cd] %@ and unique == FALSE))"];
    [arguments addObject: searchTerm];
    [arguments addObject: searchTerm];
}

# pragma mark - Table selection

-(NSString*)notificationName
{
    return kCurrentShipChanged;
}

#pragma mark - Showing items

-(BOOL)containsThisKind:(id)item
{
    return [item isMemberOfClass: [DockShip class]];
}


@end
