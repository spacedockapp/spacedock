#import "DockFlagshipTabController.h"

#import "DockAppDelegate.h"
#import "DockEquippedShip+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockSquad+Addons.h"

@implementation DockFlagshipTabController

# pragma mark - Table selection

-(NSString*)notificationName
{
    return @"flagshipTabSelection";
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
    DockFlagship* flagship = (DockFlagship*)item;
    return [flagship compatibleWithShip: ship.ship];
}

-(DockEquippedUpgrade*)addItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    DockFlagship* flagship = (DockFlagship*)item;
    NSDictionary* info = [ship becomeFlagship: flagship];
    if (info != nil) {
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setMessageText: info[@"message"]];
        [alert setInformativeText: info[@"info"]];
        [alert setAlertStyle: NSInformationalAlertStyle];
        [alert beginSheetModalForWindow: [self.appDelegate window]
                          modalDelegate: self.appDelegate
                         didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo: nil];
    }
    return nil;
}

#pragma mark - Showing items

-(BOOL)containsThisKind:(id)item
{
    return [item isMemberOfClass: [DockFlagship class]];
}

@end
