#import "DockTopMenuViewController.h"

#import "DockConstants.h"
#import "DockResourcesViewController.h"
#import "DockSetsListViewController.h"
#import "DockShipsViewController.h"
#import "DockSquadsListController.h"
#import "DockUpgradesViewController.h"
#import "DockFlagshipsViewController.h"
#import "DockReferenceViewController.h"
#import "DockDataLoader.h"
#import "DockDataUpdater.h"

@interface DockTopMenuViewController ()
@property (strong, nonatomic) UIAlertView* loadingAlert;
@end

@implementation DockTopMenuViewController

#pragma mark - Appearing
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* dataVersion = [NSString stringWithFormat:@"Data Version: %@",[defaults stringForKey: kSpaceDockCurrentDataVersionKey]];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:dataVersion];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    if (_managedObjectContext == nil) {
        _loadingAlert = [[UIAlertView alloc] initWithTitle:@"Loading Data" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [_loadingAlert show];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = CGPointMake(_loadingAlert.bounds.size.width / 2, _loadingAlert.bounds.size.height - 50);
        [_loadingAlert addSubview:indicator];
        [indicator startAnimating];
    }
    UIToolbar* toolbar = self.navigationController.toolbar;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* settings = [[UIBarButtonItem alloc] initWithTitle:@"\u2699\U0000FE0E" style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings:)];
    [toolbar setItems:[NSArray arrayWithObjects:spacer,settings, nil] animated:YES];
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [_loadingAlert dismissWithClickedButtonIndex: 0 animated: YES];
    _loadingAlert = nil;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* dataVersion = [NSString stringWithFormat:@"Data Version: %@",[defaults stringForKey: kSpaceDockCurrentDataVersionKey]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:dataVersion];
    
    DockDataUpdater* updater = [[DockDataUpdater alloc] init];
    [updater checkForNewDataVersion:^(NSString *remoteVersion, NSData *downloadData, NSError *error) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* currentVersion = [defaults stringForKey: kSpaceDockCurrentDataVersionKey];
        if ([currentVersion compare:remoteVersion] == NSOrderedAscending) {
            UIToolbar* toolbar = self.navigationController.toolbar;
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem* update = [[UIBarButtonItem alloc] initWithTitle:@"Game Data Update Available" style:UIBarButtonItemStylePlain target:self action:@selector(refresh:)];
            [toolbar setItems:[NSArray arrayWithObjects:spacer,update,spacer,nil] animated:YES];
        } else {
            UIToolbar* toolbar = self.navigationController.toolbar;
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem* settings = [[UIBarButtonItem alloc] initWithTitle:@"\u2699\U0000FE0E" style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings:)];
            [toolbar setItems:[NSArray arrayWithObjects:spacer,settings, nil] animated:YES];
        }
    }];

}

#pragma mark - Segue management

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return _managedObjectContext != nil;
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString: @"GoToShips"]) {
        id destination = [segue destinationViewController];
        DockShipsViewController* shipsViewController = (DockShipsViewController*)destination;
        shipsViewController.managedObjectContext = self.managedObjectContext;
        [shipsViewController clearTarget];
    } else if ([[segue identifier] isEqualToString: @"GoToSquads"]) {
        id destination = [segue destinationViewController];
        DockSquadsListController* controller = (DockSquadsListController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.targetSquad = _targetSquad;
    } else if ([[segue identifier] isEqualToString: @"GoToCaptains"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Captain";
        controller.upgradeTypeName = @"Captains";
    } else if ([[segue identifier] isEqualToString: @"GoToCrew"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Crew";
        controller.upgradeTypeName = @"Crew";
    } else if ([[segue identifier] isEqualToString: @"GoToTalents"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Talent";
        controller.upgradeTypeName = @"Talents";
    } else if ([[segue identifier] isEqualToString: @"GoToBorg"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Borg";
        controller.upgradeTypeName = @"Borg Upgrades";
    } else if ([[segue identifier] isEqualToString: @"GoToSquadron"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Squadron";
        controller.upgradeTypeName = @"Squadron Upgrades";
    } else if ([[segue identifier] isEqualToString: @"GoToTech"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Tech";
        controller.upgradeTypeName = @"Tech";
    } else if ([[segue identifier] isEqualToString: @"GoToWeapons"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = @"Weapon";
        controller.upgradeTypeName = @"Weapons";
    } else if ([[segue identifier] isEqualToString: @"GoToAdmirals"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = kAdmiralUpgradeType;
        controller.upgradeTypeName = @"Admirals";
    } else if ([[segue identifier] isEqualToString: @"GoToFleetCaptains"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = kFleetCaptainUpgradeType;
        controller.upgradeTypeName = @"Fleet Captains";
    } else if ([[segue identifier] isEqualToString: @"GoToOfficers"]) {
        id destination = [segue destinationViewController];
        DockUpgradesViewController* controller = (DockUpgradesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.upType = kOfficerUpgradeType;
        controller.upgradeTypeName = @"Officers";
    } else if ([[segue identifier] isEqualToString: @"GoToResources"]) {
        id destination = [segue destinationViewController];
        DockResourcesViewController* controller = (DockResourcesViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString: @"GoToFlagships"]) {
        id destination = [segue destinationViewController];
        DockFlagshipsViewController* controller = (DockFlagshipsViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString: @"GoToSets"]) {
        id destination = [segue destinationViewController];
        DockSetsListViewController* controller = (DockSetsListViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString: @"GoToReference"]) {
        id destination = [segue destinationViewController];
        DockReferenceViewController* controller = (DockReferenceViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
    }
    _targetSquad = nil;
}

-(void)showSquad:(DockSquad*)squad
{
    _targetSquad = squad;
    [self performSegueWithIdentifier: @"GoToSquads" sender: self];
}
-(void)refresh:(UIRefreshControl *)refresh
{
    DockDataUpdater* updater = [[DockDataUpdater alloc] init];
    UIToolbar* toolbar = self.navigationController.toolbar;
    UIProgressView* progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    UILabel* progressLabel = [[UILabel alloc] init];
    [progressLabel setText:@"Loading latest game data..."];
    [progressLabel setTextAlignment:NSTextAlignmentCenter];
    [progressView addSubview:progressLabel];
    [progressLabel setFrame:CGRectMake(0, 0, toolbar.frame.size.width, toolbar.frame.size.height/2)];
    [progressLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* update = [[UIBarButtonItem alloc] initWithCustomView:progressView];
    [progressView setFrame:CGRectMake(0, toolbar.frame.size.height/2, toolbar.frame.size.width*.9, toolbar.frame.size.height/2)];
    [toolbar setItems:[NSArray arrayWithObjects:spacer,update,spacer,nil] animated:YES];
    updater.progressBar = progressView;
    [updater checkForNewData:^(NSString *remoteVersion, NSData *downloadData, NSError *error) {
        [self handleNewData:remoteVersion path:downloadData error:error];
    }];
}
-(void)handleNewData:(NSString*)remoteVersion path:(NSData*)downloadData error:(NSError*)error
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentVersion = [defaults stringForKey: kSpaceDockCurrentDataVersionKey];
    if ([currentVersion compare:remoteVersion] == NSOrderedAscending) {
        NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
        NSString* appData = [url path];
        NSString* xmlFile = [appData stringByAppendingPathComponent: @"Data.xml"];
        [downloadData writeToFile:xmlFile atomically:NO];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        DockDataLoader* loader = [[DockDataLoader alloc] initWithContext: self.managedObjectContext];
        NSError* err;
        [loader loadData: &err];
        [loader validateSpecials];
        [loader cleanupDatabase];
        
        NSString* dataVersion = [NSString stringWithFormat:@"Data Version: %@",[defaults stringForKey: kSpaceDockCurrentDataVersionKey]];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:dataVersion];
    }
    UIToolbar* toolbar = self.navigationController.toolbar;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* settings = [[UIBarButtonItem alloc] initWithTitle:@"\u2699\U0000FE0E" style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings:)];
    [toolbar setItems:[NSArray arrayWithObjects:spacer,settings, nil] animated:YES];
    [self.refreshControl endRefreshing];
}
-(void)goToSettings:(NSObject*)source {
    NSURL* settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:settings];
}
@end
