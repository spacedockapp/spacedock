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
@property (assign, nonatomic) BOOL lightheader;

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
    renderer.lightHeader = _lightheader;
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
@property (assign, nonatomic) BOOL lightheader;
@property (nonatomic, strong) UIDocumentInteractionController* shareController;

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
    _lightheader = [defaults boolForKey: kLightHeaderKey];
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
    DockBuildSheetPrintRenderer* renderer = [[DockBuildSheetPrintRenderer alloc] initWithSquad: _squad];
    renderer.name = _nameField.text;
    renderer.email = _emailField.text;
    renderer.event = _eventField.text;
    renderer.faction = _factionField.text;
    renderer.date = _datePicker.date;
    renderer.blindbuy = _blindbuySwitch.on;
    renderer.lightheader = _lightheader;

    NSString* tempPDF = NSTemporaryDirectory();
    tempPDF = [tempPDF stringByAppendingFormat:@"%@.pdf",_squad.name];
    
    UIGraphicsBeginPDFContextToFile(tempPDF, CGRectZero, nil);
    [renderer prepareForDrawingPages: NSMakeRange(0, renderer.numberOfPages)];
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    for ( int i = 0 ; i < renderer.numberOfPages ; i++ ) {
        UIGraphicsBeginPDFPage();
        [renderer drawPageAtIndex:i inRect: bounds];
    }
    UIGraphicsEndPDFContext();
    
    NSURL* url = [[NSURL alloc] initFileURLWithPath: tempPDF];
    _shareController = [UIDocumentInteractionController interactionControllerWithURL: url];
    _shareController.delegate = self;
    _shareController.name = [NSString stringWithFormat:@"Fleet Build Sheet for %@",_squad.name];
    //_shareController.UTI = @"pdf";
    NSLog(@"View bounds = %f,%f",self.view.bounds.origin.x,self.view.bounds.origin.y);
    //bool didShow = [_shareController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
    bool didShow = [_shareController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    if (!didShow)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Share"
                                                        message:@"This squad list could not be shared."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSURL* url = _shareController.URL;
    [[NSFileManager defaultManager] removeItemAtURL: url error: nil];
    _shareController = nil;
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
