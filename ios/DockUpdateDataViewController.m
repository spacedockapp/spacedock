#import "DockUpdateDataViewController.h"

#import "DockDataUpdater.h"
#import "DockAppDelegate.h"
#import "DockConstants.h"

@interface DockUpdateDataViewController ()
@property (strong, nonatomic) DockDataUpdater* updater;
@property (strong, nonatomic) NSData* downloadedData;
@property (strong, nonatomic) IBOutlet UIButton* checkButton;
@property (strong, nonatomic) IBOutlet UIButton* resetButton;
@end

@implementation DockUpdateDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    DockAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [_resetButton setEnabled: appDelegate.hasUpdatedData];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        DockAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate installData: _downloadedData];
        [_resetButton setEnabled: appDelegate.hasUpdatedData];
    }
}

-(void)handleNewData:(NSString*)remoteVersion data:(NSData*)downloadData error:(NSError*)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    _updater = nil;
    _downloadedData = downloadData;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentVersion = [defaults stringForKey: kSpaceDockCurrentDataVersionKey];
    if (![currentVersion isEqualToString: remoteVersion]) {
        NSString* title = @"New Game Data Available";
        NSString* info = [NSString stringWithFormat: @"Current data version is %@ and version %@ is available Would you like to update?", currentVersion, remoteVersion];
        UIAlertView* view = [[UIAlertView alloc] initWithTitle: title
                                                       message: info
                                                      delegate: self
                                             cancelButtonTitle: @"Cancel"
                                             otherButtonTitles: @"Update", nil];
        [view show];
    } else {
        NSString* title = @"Game Data Up-to-date";
        NSString* info = [NSString stringWithFormat: @"Current data version is %@ and is the latest version available.", currentVersion];
        UIAlertView* view = [[UIAlertView alloc] initWithTitle: title
                                                       message: info
                                                      delegate: nil
                                             cancelButtonTitle: nil
                                             otherButtonTitles: @"OK", nil];
        [view show];
    }
}

-(IBAction)checkForNewData:(id)sender
{
    if (_updater == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
        _updater = [[DockDataUpdater alloc] init];
        id completion = ^(NSString* remoteVersion, NSData* downloadData, NSError* error) {
            [self handleNewData: remoteVersion data: downloadData error: error];
        };
        [_updater checkForNewData: completion];
    }
}

-(IBAction)revertData:(id)sender
{
    DockAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate revertData];
    [_resetButton setEnabled: appDelegate.hasUpdatedData];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentVersion = [defaults stringForKey: kSpaceDockCurrentDataVersionKey];
    NSString* title = @"Game Data Up-to-date";
    NSString* info = [NSString stringWithFormat: @"Data reverted to version is %@.", currentVersion];
    UIAlertView* view = [[UIAlertView alloc] initWithTitle: title
                                                   message: info
                                                  delegate: nil
                                         cancelButtonTitle: nil
                                         otherButtonTitles: @"OK", nil];
    [view show];
}

@end
