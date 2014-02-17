#import "DockBuildSheetViewController.h"

#import "DockBuildSheetRenderer.h"
#import "DockBuildSheetView.h"

@interface DockBuildSheetPrintRenderer : UIPrintPageRenderer {
    DockSquad* _squad;
}
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* event;
@property (strong, nonatomic) NSString* faction;
@property (strong, nonatomic) NSDate* date;
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
    [renderer draw: contentRect];
}

@end

@interface DockBuildSheetViewController ()
@property (assign, nonatomic) IBOutlet UIDatePicker* datePicker;
@property (assign, nonatomic) IBOutlet UITextField* nameField;
@property (assign, nonatomic) IBOutlet UITextField* emailField;
@property (assign, nonatomic) IBOutlet UITextField* eventField;
@property (assign, nonatomic) IBOutlet UITextField* factionField;
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
    [super viewWillAppear: animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: _nameField.text forKey: kPlayerNameKey];
    [defaults setObject: _emailField.text forKey: kPlayerEmailKey];
    [defaults setObject: _factionField.text forKey: kEventFactionKey];
    [defaults setObject: _eventField.text forKey: kEventNameKey];

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
    controller.printPageRenderer = renderer;
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
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

@end
