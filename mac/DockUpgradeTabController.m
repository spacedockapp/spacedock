#import "DockUpgradeTabController.h"

#import "DockAppDelegate.h"
#import "DockCaptain+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUpgrade+Addons.h"

@implementation DockUpgradeTabController

# pragma mark - Table selection

-(NSString*)notificationName
{
    return kCurrentUpgradeChanged;
}

#pragma mark - Filtering

-(NSString*)upgradeType
{
    return self.appDelegate.upType;
}

-(void)addAdditionalPredicates:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    NSString* upgradeType = [self upgradeType];
    if (upgradeType != nil) {
        [formatParts addObject: @"(upType = %@)"];
        [arguments addObject: upgradeType];
    }
    [formatParts addObject: @"(not upType like 'Captain') and (not upType like 'Admiral') and (not upType like 'Fleet Captain') and (not upType like 'Officer') and (not placeholder == YES)"];
}

-(void)updatePredicates
{
    [super updatePredicates];
}

#pragma mark - Current Ship

-(BOOL)dependsOnCurrentTargetShip
{
    return YES;
}

#pragma mark - Adding to ship

-(BOOL)canAddItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship
{
    DockCaptain* captain = (DockCaptain*)item;
    NSError* error;
    return [ship.squad canAddCaptain: captain toShip: ship error: &error];
}

-(void)explainCantAddUpgrade:(DockEquippedShip*)ship upgrade:(DockUpgrade*)upgrade
{
    NSDictionary* reasons = [ship explainCantAddUpgrade: upgrade];
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText: reasons[@"message"]];
    [alert setInformativeText: reasons[@"info"]];
    [alert setAlertStyle: NSInformationalAlertStyle];
    [alert beginSheetModalForWindow: self.window
                      modalDelegate: self
                     didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
}

-(DockEquippedUpgrade*)addItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship inSquad:(DockSquad*)squad selectedItem:(id)selectedItem
{
    DockUpgrade* upgrade = (DockUpgrade*)item;
    if ([upgrade isUnique]) {
        DockEquippedUpgrade* existing = [squad containsUpgradeWithName: upgrade.title];

        if (existing) {
            NSError* error;
            [squad canAddUpgrade: upgrade toShip: ship error: &error];
            [self explainCantUniqueUpgrade: error];
            return nil;
        }
    }

    if (![ship canAddUpgrade: upgrade]) {
        [self explainCantAddUpgrade: ship upgrade: upgrade];
        return nil;
    }

    DockEquippedUpgrade* maybeReplace = nil;

    if ([selectedItem isKindOfClass: [DockEquippedUpgrade class]]) {
        maybeReplace = (DockEquippedUpgrade*)selectedItem;
    }
    return [ship addUpgrade: upgrade maybeReplace: maybeReplace];
}

#pragma mark - Observing

-(void)startObserving
{
    [super startObserving];
    [self.appDelegate addObserver: self forKeyPath: @"upType" options: 0 context: 0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.appDelegate && [keyPath isEqualToString: @"upType"]) {
        [self updatePredicates];
    } else {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

#pragma mark - Showing items

-(BOOL)containsThisKind:(id)item
{
    if (![item isKindOfClass: [DockUpgrade class]]) {
        return NO;
    }

    if ([item isKindOfClass: [DockCaptain class]]) {
        return NO;
    }

    return YES;
}

-(void)resetFiltersForItem:(id)item
{
    [super resetFiltersForItem: item];
    DockUpgrade* upgrade = item;
    NSString* upType = upgrade.upType;
    NSString* filterUpType = self.appDelegate.upType;
    if (![upType isEqualToString: filterUpType]) {
        self.appDelegate.upType = nil;
    }
}
@end
