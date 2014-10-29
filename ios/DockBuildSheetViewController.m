#import "DockBuildSheetViewController.h"

#import "DockBuildSheetRenderer.h"
#import "DockBuildSheetView.h"
#import "DockEquippedShip+Addons.h"
#import "DockSquad+Addons.h"

@interface DockBuildSheetPrintRenderer : UIPrintPageRenderer {
    DockSquad* _squad;
}
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* event;
@property (strong, nonatomic) NSString* faction;
@property (strong, nonatomic) NSDate* date;
@property (assign, nonatomic) BOOL blindbuy;
-(id)initWithSquad:(DockSquad*)squad;
@end

@implementation DockBuildSheetPrintRenderer

-(id)initWithSquad:(DockSquad*)squad
{
    self = [super init];
    if (self != nil) {
        _squad = squad;
    }
    return self;
}

- (NSInteger)numberOfPages
{
    if (_squad.equippedShips.count > 4) {
        return 2;
    }
    return 1;
}

- (void)drawContentForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)contentRect
{
    DockBuildSheetRenderer* renderer = [[DockBuildSheetRenderer alloc] initWithSquad: _squad];
    renderer.name = _name;
    renderer.email = _email;
    renderer.faction = _faction;
    renderer.event = _event;
    renderer.date = _date;
    renderer.blindbuy = _blindbuy;
    renderer.pageIndex = pageIndex;
    [renderer draw: contentRect];
}

@end

@interface DockBuildSheetViewController ()
@property (assign, nonatomic) IBOutlet UIDatePicker* datePicker;
@property (assign, nonatomic) IBOutlet UITextField* nameField;
@property (assign, nonatomic) IBOutlet UITextField* emailField;
@property (assign, nonatomic) IBOutlet UITextField* eventField;
@property (assign, nonatomic) IBOutlet UITextField* factionField;
@property (assign, nonatomic) IBOutlet UISwitch* blindbuySwitch;
@end

@implementation DockBuildSheetViewController

-(void)setSquad:(DockSquad *)squad
{
    _squad = squad;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _nameField.text = [defaults stringForKey: kPlayerNameKey];
    _emailField.text = [defaults stringForKey: kPlayerEmailKey];
    _factionField.text = [defaults stringForKey: kEventFactionKey];
    _eventField.text = [defaults stringForKey: kEventNameKey];
    _blindbuySwitch.on = [defaults boolForKey: kBlindBuyKey];
    
    [super viewWillAppear: animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: _nameField.text forKey: kPlayerNameKey];
    [defaults setObject: _emailField.text forKey: kPlayerEmailKey];
    [defaults setObject: _factionField.text forKey: kEventFactionKey];
    [defaults setObject: _eventField.text forKey: kEventNameKey];
    [defaults setBool: _blindbuySwitch.on forKey: kBlindBuyKey];
    
    [super viewWillDisappear: animated];
}

-(IBAction)print:(id)sender
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if(!controller){
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    DockBuildSheetPrintRenderer* renderer = [[DockBuildSheetPrintRenderer alloc] initWithSquad: _squad];
    renderer.name = _nameField.text;
    renderer.email = _emailField.text;
    renderer.event = _eventField.text;
    renderer.faction = _factionField.text;
    renderer.date = _datePicker.date;
    renderer.blindbuy = _blindbuySwitch.on;
    controller.printPageRenderer = renderer;
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
        } else {
            NSString* selectedPrinter = printController.printInfo.dictionaryRepresentation[@"UIPrintInfoPrinterIDKey"];
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue: selectedPrinter forKey: @"UIPrintInfoPrinterIDKey"];
        }
    };
    
    // Obtain a printInfo so that we can set our printing defaults.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* infoDict = @{};
    NSString* selectedPrinter = [defaults valueForKey: @"UIPrintInfoPrinterIDKey"];
    if (selectedPrinter != nil) {
        infoDict = @{ @"UIPrintInfoPrinterIDKey": selectedPrinter};
    }
    UIPrintInfo *printInfo = [UIPrintInfo printInfoWithDictionary: infoDict];
    // This application produces General content that contains color.
    printInfo.outputType = UIPrintInfoOutputGeneral;
    // We'll use the URL as the job name.
    printInfo.jobName = @"sheet";
    // Set duplex so that it is available if the printer supports it. We are
    // performing portrait printing so we want to duplex along the long edge.
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    // Use this printInfo for this print job.
    controller.printInfo = printInfo;
    
    // Be sure the page range controls are present for documents of > 1 page.
    controller.showsPageRange = YES;
    [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameField){
        [_emailField becomeFirstResponder];
    } else if (textField == _emailField) {
        [_eventField becomeFirstResponder];
    } else if (textField == _eventField) {
        [_factionField becomeFirstResponder];
    } else if ( textField == _factionField) {
        [_datePicker becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}


@end
