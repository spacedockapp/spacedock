#import "DockBuildSheetViewController.h"

#import "DockBuildSheetRenderer.h"
#import "DockBuildSheetView.h"

@interface DockBuildSheetPrintRenderer : UIPrintPageRenderer

@end

@implementation DockBuildSheetPrintRenderer

- (NSInteger)numberOfPages
{
    return 1;
}

- (void)drawContentForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)contentRect
{
    DockBuildSheetRenderer* renderer = [[DockBuildSheetRenderer alloc] init];
    [renderer draw: contentRect];
}

@end

@interface DockBuildSheetViewController () <UIScrollViewDelegate>
@property (assign, nonatomic) IBOutlet DockBuildSheetView* sheetView;
@end

@implementation DockBuildSheetViewController

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _sheetView;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    UIScrollView* scrollView = (UIScrollView*)self.view;
    scrollView.contentSize = _sheetView.bounds.size;
    scrollView.delegate = self;
    scrollView.minimumZoomScale=0.25;
    scrollView.maximumZoomScale=1;
    scrollView.zoomScale = 1;
    _sheetView.squad = _squad;
    NSMutableData* pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    UIGraphicsBeginPDFPage();
    CGRect pageBounds = UIGraphicsGetPDFContextBounds();
    CGRect blackBox = CGRectMake(0, 0, pageBounds.size.width, 100);
    [[UIColor blackColor] set];
    UIBezierPath* blackBoxPath = [UIBezierPath bezierPathWithRect: blackBox];
    [blackBoxPath fill];
    UIGraphicsEndPDFContext();
}

-(IBAction)print:(id)sender
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if(!controller){
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    DockBuildSheetPrintRenderer* renderer = [[DockBuildSheetPrintRenderer alloc] init];
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
