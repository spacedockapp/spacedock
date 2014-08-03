#import "DockInspector.h"

#import "DockAdmiralTabController.h"
#import "DockAppDelegate.h"
#import "DockCaptain+Addons.h"
#import "DockEquippedFlagship+MacAddons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagship+Addons.h"
#import "DockMoveGrid.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquadDetailController.h"
#import "DockResource+Addons.h"
#import "DockTabControllerConstants.h"
#import "DockTabDelegate.h"
#import "DockUpgrade+Addons.h"

@interface DockInspector ()
@property (strong, nonatomic) DockShip* equippedShip;
@property (strong, nonatomic) DockShip* listShip;
@end

@implementation DockInspector

+(NSSet*)keyPathsForValuesAffectingCurrentShip
{
    return [NSSet setWithObjects: @"currentListShip", @"currentEquippedShip", @"squadIsActive", nil];
}

+(NSSet*)keyPathsForValuesAffectingCurrentCaptain
{
    return [NSSet setWithObjects: @"currentListCaptain", @"currentEquippedCaptain", @"squadIsActive", nil];
}

+(NSSet*)keyPathsForValuesAffectingCurrentAdmiral
{
    return [NSSet setWithObjects: @"currentListAdmiral", @"currentEquippedAdmiral", @"squadIsActive", nil];
}

+(NSSet*)keyPathsForValuesAffectingCurrentUpgrade
{
    return [NSSet setWithObjects: @"currentListUpgrade", @"currentEquippedUpgrade", @"squadIsActive", nil];
}

+(NSSet*)keyPathsForValuesAffectingCurrentFlagship
{
    return [NSSet setWithObjects: @"currentListFlagship", @"currentEquippedFlagship", @"squadIsActive", nil];
}

+(NSSet*)keyPathsForValuesAffectingCurrentSetName
{
    return [NSSet setWithObjects: @"currentListSetName", @"currentEquippedSetName", @"currentTabIdentifier", @"squadIsActive", nil];
}

+(NSSet*)keyPathsForValuesAffectingCurrentTabIdentifier
{
    return [NSSet setWithObjects: @"currentListTabIdentifier", @"currentEquippedTabIdentifier", @"squadIsActive", nil];
}

+(NSSet*)keyPathsForValuesAffectingSquadIsActive
{
    return [NSSet setWithObjects: @"firstResponderIdent", nil];
}


static id extractSelectedItem(id controller)
{
    NSArray* selectedItems = [controller selectedObjects];

    if (selectedItems.count > 0) {
        return selectedItems[0];
    }

    return nil;
}

-(NSString*)identToTabIdent:(NSString*)ident
{
    NSDictionary* d = @{
        @"captainsTable" : @"captain",
        @"admiralsTable" : @"admiral",
        @"upgradeTable" : @"upgrade",
        @"shipsTable" : @"ship",
        @"resourcesTable" : @"resource",
        @"flagshipsTable" : @"flagship",
        @"referenceTable" : @"reference"
    };
    return d[ident];
}

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context
{
    @try {
       id responder = [_mainWindow firstResponder];
        NSString* ident = [responder identifier];
        if (object == _mainWindow) {
            self.firstResponderIdent = ident;
            [self updateMoveGrid];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"caught exception %@", exception);
    }
    @finally {
    }
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.shipDetailTab = @"forShip";
    self.currentListTabIdentifier = self.currentEquippedTabIdentifier = @"ship";
    [_inspector setFloatingPanel: YES];
    [_mainWindow addObserver: self forKeyPath: @"firstResponder" options: 0 context: 0];

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(admiralChanged:) name: kCurrentAdmiralChanged object: nil];
    [center addObserver: self selector: @selector(captainChanged:) name: kCurrentCaptainChanged object: nil];
    [center addObserver: self selector: @selector(upgradeChanged:) name: kCurrentUpgradeChanged object: nil];
    [center addObserver: self selector: @selector(flagshipChanged:) name: kCurrentFlagshipChanged object: nil];
    [center addObserver: self selector: @selector(shipChanged:) name: kCurrentShipChanged object: nil];
    [center addObserver: self selector: @selector(resourceChanged:) name: kCurrentResourceChanged object: nil];
    [center addObserver: self selector: @selector(referenceChanged:) name: kCurrentReferenceChanged object: nil];
    [center addObserver: self selector: @selector(topTabChanged:) name: kTabSelectionChanged object: nil];
    [center addObserver: self selector: @selector(equippedUpgradeChanged:) name: kCurrentEquippedUpgrade object: nil];
}

-(void)show
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: YES forKey: kInspectorVisible];
    [_inspector orderFront: self];
}

-(BOOL)windowShouldClose:(id)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: NO forKey: kInspectorVisible];
    return YES;
}

-(IBAction)toggleShipClass:(id)sender
{
    if ([self.shipDetailTab isEqualToString: @"forClass"]) {
        self.shipDetailTab = @"forShip";
    } else {
        self.shipDetailTab = @"forClass";
    }
}

#pragma mark - Properties

-(BOOL)squadIsActive
{
    return [self.firstResponderIdent isEqualToString: @"squadsDetailOutline"];
}

-(NSDictionary*)currentShip
{
    if ([self squadIsActive]) {
        return self.currentEquippedShip;
    }
    return self.currentListShip;
}

-(NSDictionary*)currentCaptain
{
    if ([self squadIsActive]) {
        return self.currentEquippedCaptain;
    }
    return self.currentListCaptain;
}

-(NSDictionary*)currentAdmiral
{
    if ([self squadIsActive]) {
        return self.currentEquippedAdmiral;
    }
    return self.currentListAdmiral;
}

-(NSDictionary*)currentUpgrade
{
    if ([self squadIsActive]) {
        return self.currentEquippedUpgrade;
    }
    return self.currentListUpgrade;
}

-(NSDictionary*)currentFlagship
{
    if ([self squadIsActive]) {
        return self.currentEquippedFlagship;
    }
    return self.currentListFlagship;
}

-(NSString*)currentSetName
{
    if ([self.firstResponderIdent isEqualToString: @"squadsTable"]) {
        return @"";
    }

    if ([self squadIsActive]) {
        return self.currentEquippedSetName;
    }
    return self.currentListSetName;
}

-(NSString*)currentTabIdentifier
{
    if ([self.firstResponderIdent isEqualToString: @"squadsTable"]) {
        return @"blank";
    }
    if ([self squadIsActive]) {
        return self.currentEquippedTabIdentifier;
    }
    return self.currentListTabIdentifier;
}

-(void)updateMoveGrid
{
    if ([self squadIsActive]) {
        _moveGrid.ship = self.equippedShip;
    } else {
        _moveGrid.ship = self.listShip;
    }
}

#pragma mark - Notifications

static NSDictionary* copyProperties(id target, NSArray* propertyList)
{
    NSMutableDictionary* props = [[NSMutableDictionary alloc] initWithCapacity: propertyList.count];
    for (NSString* name in propertyList) {
        id value = [target valueForKey: name];
        if (value != nil) {
            [props setObject: value forKey: name];
        }
    }
    return [NSDictionary dictionaryWithDictionary: props];
}

-(NSDictionary*)extractAdmiralProperties:(DockAdmiral*)admiral
{
    NSArray* displayedAdmiralProperties = @[
        @"setName",
        @"styledSkillModifier",
        @"title",
        @"admiralAbility",
        @"admiralCost",
        @"skill"
    ];
    return copyProperties(admiral, displayedAdmiralProperties);
}

-(void)admiralChanged:(NSNotification*)notification
{
    self.currentListAdmiral = [self extractAdmiralProperties: notification.object];
    if ([self.currentListTabIdentifier isEqualToString: @"admiral"]) {
        self.currentEquippedSetName = self.currentListAdmiral[@"setName"];
    }
}

-(NSDictionary*)extractCaptainProperties:(DockCaptain*)captain
{
    NSArray* displayedCaptainProperties = @[
        @"setName",
        @"styledSkill",
        @"title",
        @"ability",
        @"cost",
        @"skill"
    ];
    return copyProperties(captain, displayedCaptainProperties);
}

-(void)captainChanged:(NSNotification*)notification
{
    self.currentListCaptain = [self extractCaptainProperties: notification.object];
    if ([self.currentListTabIdentifier isEqualToString: @"captain"]) {
        self.currentListSetName = self.currentListCaptain[@"setName"];
    }
}

-(NSDictionary*)extractUpgradeProperties:(DockUpgrade*)upgrade
{
    NSArray* displayedUgradeProperties = @[
        @"setName",
        @"title",
        @"ability",
        @"cost",
        @"optionalRange",
        @"optionalAttack",
    ];
    return copyProperties(upgrade, displayedUgradeProperties);
}

-(void)upgradeChanged:(NSNotification*)notification
{
    self.currentListUpgrade = [self extractUpgradeProperties: notification.object];
    if ([self.currentListTabIdentifier isEqualToString: @"upgrade"]) {
        self.currentListSetName = self.currentListUpgrade[@"setName"];
    }
}

-(NSDictionary*)extractFlagshipProperties:(DockFlagship*)flagship
{
    NSArray* displayedFlagshipProperties = @[
        @"setName",
        @"ability",
        @"agility",
        @"attack",
        @"capabilities",
        @"hull",
        @"shield",
        @"title",
    ];
    return copyProperties(flagship, displayedFlagshipProperties);
}

-(void)flagshipChanged:(NSNotification*)notification
{
    self.currentListFlagship = [self extractFlagshipProperties: notification.object];
    if ([self.currentListTabIdentifier isEqualToString: @"flagship"]) {
        self.currentListSetName = self.currentListFlagship[@"setName"];
    }
}

-(NSDictionary*)extractShipProperties:(DockShip*)ship
{
    NSArray* displayedShipProperties = @[
        @"setName",
        @"ability",
        @"agility",
        @"attack",
        @"capabilities",
        @"cost",
        @"formattedFrontArc",
        @"formattedRearArc",
        @"hull",
        @"shield",
        @"title",
    ];
    return copyProperties(ship, displayedShipProperties);
}

-(void)shipChanged:(NSNotification*)notification
{
    self.currentListShip = [self extractShipProperties: notification.object];
    self.listShip = notification.object;
    [self updateMoveGrid];
    self.currentListSetName = self.currentListShip[@"setName"];
}

-(void)resourceChanged:(NSNotification*)notification
{
    NSArray* displayedResourceProperties = @[
        @"setName",
        @"ability",
        @"cost",
        @"title",
    ];
    self.currentResource = copyProperties(notification.object, displayedResourceProperties);
    if ([self.currentListTabIdentifier isEqualToString: @"resource"]) {
        self.currentListSetName = self.currentResource[@"setName"];
    }
}

-(void)referenceChanged:(NSNotification*)notification
{
    NSArray* displayedReferenceProperties = @[
        @"setName",
        @"ability",
        @"title",
    ];
    self.currentReference = copyProperties(notification.object, displayedReferenceProperties);
    if ([self.currentListTabIdentifier isEqualToString: @"reference"]) {
        self.currentListSetName = self.currentReference[@"setName"];
    }
}

-(void)equippedUpgradeChanged:(NSNotification*)notification
{
    id object = notification.object;
    if ([object isMemberOfClass: [DockEquippedFlagship class]]) {
        DockEquippedFlagship* efs = object;
        self.currentEquippedFlagship = [self extractFlagshipProperties: efs.flagship];
        self.currentEquippedSetName = self.currentEquippedFlagship[@"setName"];
        self.currentEquippedTabIdentifier = @"flagship";
    } else if ([object isKindOfClass: [DockEquippedShip class]]) {
        DockEquippedShip* es = object;
        self.currentEquippedShip = [self extractShipProperties: es.ship];
        self.equippedShip = es.ship;
        [self updateMoveGrid];
        self.currentEquippedSetName = self.currentEquippedShip[@"setName"];
        self.currentEquippedTabIdentifier = @"ship";
    } else {
        DockEquippedUpgrade* equippedUpgrade = notification.object;
        DockUpgrade* upgrade = equippedUpgrade.upgrade;
        if (upgrade.isPlaceholder) {
            self.currentEquippedTabIdentifier = @"blank";
            self.currentEquippedSetName = @"";
            self.currentEquippedUpgrade = @{};
        } else {
            if (upgrade.isCaptain) {
                self.currentEquippedCaptain = [self extractCaptainProperties: (DockCaptain*)upgrade];
                self.currentEquippedSetName = self.currentEquippedCaptain[@"setName"];
                self.currentEquippedTabIdentifier = @"captain";
            } else if (upgrade.isAdmiral) {
                self.currentEquippedTabIdentifier = @"admiral";
                self.currentEquippedAdmiral = [self extractAdmiralProperties: (DockAdmiral*)upgrade];
                self.currentEquippedSetName = self.currentEquippedAdmiral[@"setName"];
            } else {
                self.currentEquippedTabIdentifier = @"upgrade";
                self.currentEquippedUpgrade = [self extractUpgradeProperties: upgrade];
                self.currentEquippedSetName = self.currentEquippedUpgrade[@"setName"];
            }
        }
    }
}

-(void)topTabChanged:(NSNotification*)notification
{
    NSTabView* tabView = notification.object;
    NSString* ident = [[tabView selectedTabViewItem] identifier];
    if ([ident isEqualToString: @"tabReference"]) {
        self.currentListTabIdentifier = @"reference";
        self.currentListSetName = self.currentReference[@"setName"];
    } else if ([ident isEqualToString: @"resources"]) {
        self.currentListTabIdentifier = @"resource";
        self.currentListSetName = self.currentResource[@"setName"];
    } else if ([ident isEqualToString: @"admirals"]) {
        self.currentListTabIdentifier = @"admiral";
        self.currentListSetName = self.currentListAdmiral[@"setName"];
    } else if ([ident isEqualToString: @"captains"]) {
        self.currentListTabIdentifier = @"captain";
        self.currentListSetName = self.currentListCaptain[@"setName"];
    } else if ([ident isEqualToString: @"upgrades"]) {
        self.currentListTabIdentifier = @"upgrade";
        self.currentListSetName = self.currentListUpgrade[@"setName"];
    } else if ([ident isEqualToString: @"flagships"]) {
        self.currentListTabIdentifier = @"flagship";
        self.currentListSetName = self.currentListFlagship[@"setName"];
    } else if ([ident isEqualToString: @"tabSets"]) {
        self.currentListTabIdentifier = @"blank";
        self.currentListSetName = @"";
    } else if ([ident isEqualToString: @"ships"]) {
        self.currentListTabIdentifier = @"ship";
        self.currentListSetName = self.currentListShip[@"setName"];
    }
}

@end
