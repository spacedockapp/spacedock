#import "DockUpdateDataViewController.h"

#import "DockDataUpdater.h"
#import "DockConstants.h"

@interface DockUpdateDataViewController ()
@property (strong, nonatomic) DockDataUpdater* updater;
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
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)handleNewData:(NSString*)remoteVersion data:(NSData*)downloadData error:(NSError*)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    _updater = nil;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentVersion = [defaults stringForKey: kSpaceDockCurrentDataVersionKey];
    if (![currentVersion isEqualToString: remoteVersion]) {
        NSString* title = @"New Game Data Available";
        NSString* info = [NSString stringWithFormat: @"Current data version is %@ and version %@ is available Would you like to update?", currentVersion, remoteVersion];
        UIAlertView* view = [[UIAlertView alloc] initWithTitle: title
                                                       message: info
                                                      delegate: nil
                                             cancelButtonTitle: @"Cancel"
                                             otherButtonTitles: @"Update", nil];
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

@end
