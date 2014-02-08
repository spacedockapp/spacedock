#import "DockSquadDetailController.h"

#import "DockBuildSheetViewController.h"
#import "DockConstants.h"
#import "DockEditValueController.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShipCell.h"
#import "DockEquippedShipController.h"
#import "DockResource+Addons.h"
#import "DockResourcesViewController.h"
#import "DockShip+Addons.h"
#import "DockShipsViewController.h"
#import "DockSquad+Addons.h"
#import "DockSquadsListController.h"
#import "DockUtilsMobile.h"

#import <MessageUI/MessageUI.h>

@interface DockSquadDetailController ()<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) IBOutlet UIBarButtonItem* cpyBarItem;
@end

@implementation DockSquadDetailController

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle: style];

    if (self) {
    }

    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateCost
{
    NSIndexPath* costPath = [NSIndexPath indexPathForRow: 1 inSection: 0];
    [self.tableView reloadRowsAtIndexPaths: @[costPath] withRowAnimation: UITableViewRowAnimationAutomatic];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString: @"cost"]) {
        [self performSelector: @selector(updateCost) withObject: nil afterDelay: 0];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [_squad addObserver: self forKeyPath: @"cost" options: 0 context: 0];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_squad removeObserver: self forKeyPath: @"cost"];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Details";
    }

    return @"Ships";
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }

    return _squad.equippedShips.count + 1;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    UITableViewCell* cell = nil;

    if (section == 0) {
        NSInteger row = [indexPath indexAtPosition: 1];

        if (row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier: @"resource" forIndexPath: indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier: @"detail" forIndexPath: indexPath];
        }

        if (row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = _squad.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 1) {
            cell.textLabel.text = @"Cost";
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", _squad.cost];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.textLabel.text = @"Resource";

            if (_squad.resource != nil) {
                cell.detailTextLabel.text = _squad.resource.title;
            } else {
                cell.detailTextLabel.text = @"No Resource";
            }

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else {
        NSInteger row = [indexPath indexAtPosition: 1];
        NSInteger shipCount = _squad.equippedShips.count;

        if (row == shipCount) {
            cell = [tableView dequeueReusableCellWithIdentifier: @"addShip" forIndexPath: indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier: @"ship" forIndexPath: indexPath];
            DockEquippedShipCell* shipCell = (DockEquippedShipCell*)cell;
            DockEquippedShip* es = _squad.equippedShips[row];
            shipCell.cost.text = [NSString stringWithFormat: @"%d", [es cost]];
            shipCell.details.text = [es upgradesDescription];
            NSString* t = es.plainDescription;
            if (es.flagship) {
                t = [t stringByAppendingString: @" [FS]"];
            }
            shipCell.title.text = t;
        }
    }

    return cell;
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger row = [indexPath indexAtPosition: 1];
    return section > 0 || (row == 2 && _squad.resource != nil);
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView beginUpdates];
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger row = [indexPath indexAtPosition: 1];

    if (section == 0) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            DockResource* resource = _squad.resource;

            if (resource.isSideboard) {
                NSIndexPath* sideboardPath = [NSIndexPath indexPathForRow: _squad.equippedShips.count - 1 inSection: 1];
                [self.tableView deleteRowsAtIndexPaths: @[sideboardPath] withRowAnimation: UITableViewRowAnimationNone];
            }

            _squad.resource = nil;
            [self.tableView reloadRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        }
    } else {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            DockEquippedShip* es = _squad.equippedShips[row];

            if (es.isResourceSideboard) {
                NSIndexPath* resourceIndexPath = [NSIndexPath indexPathForRow: 2 inSection: 1];
                _squad.resource = nil;
                [self.tableView reloadRowsAtIndexPaths: @[resourceIndexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
            } else {
                [_squad removeEquippedShip: es];
            }

            NSError* error;

            if (!saveItem(_squad, &error)) {
                presentError(error);
            }

            [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        }
    }

    [self.tableView endUpdates];
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger row = [indexPath indexAtPosition: 1];

    if (section == 0) {
        return row != 1;
    } else {
        NSInteger shipCount = _squad.equippedShips.count;
        return row < shipCount;
    }

    return YES;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];

    if (section == 0) {
        return 32;
    }

    return tableView.rowHeight;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* sequeIdentifier = [segue identifier];
    id destination = [segue destinationViewController];

    if ([sequeIdentifier isEqualToString: @"PickShip"]) {
        DockShipsViewController* shipsViewController = (DockShipsViewController*)destination;
        shipsViewController.managedObjectContext = [_squad managedObjectContext];
        [shipsViewController targetSquad: _squad onPicked: ^(DockShip* theShip) { [self addShip: theShip];
         }

        ];
    } else if ([sequeIdentifier isEqualToString: @"PickResource"]) {
        DockResourcesViewController* resourcesViewController = (DockResourcesViewController*)destination;
        resourcesViewController.managedObjectContext = [_squad managedObjectContext];
        [resourcesViewController targetSquad: _squad resource: _squad.resource onPicked: ^(DockResource* resource) { [self addResource: resource];
         }

        ];
    } else if ([sequeIdentifier isEqualToString: @"ShowEquippedShip"]) {
        DockEquippedShipController* controller = (DockEquippedShipController*)destination;
        NSIndexPath* indexPath = [[self tableView] indexPathForSelectedRow];
        NSInteger row = [indexPath indexAtPosition: 1];
        DockEquippedShip* es = _squad.equippedShips[row];
        controller.equippedShip = es;
    } else if ([sequeIdentifier isEqualToString: @"EditName"]) {
        DockEditValueController* editValue = (DockEditValueController*)destination;
        editValue.valueName = @"Name";
        editValue.initialValue = _squad.name;
        editValue.onSave = ^(NSString* newValue) {
            _squad.name = newValue;
            NSError* error;

            if (!saveItem(_squad, &error)) {
                presentError(error);
            }

            [self.tableView reloadData];
        };
    } else if ([[segue identifier] isEqualToString: @"BuildSheet"]) {
        id destination = [segue destinationViewController];
        DockBuildSheetViewController* target = (DockBuildSheetViewController*)destination;
        target.squad = _squad;
    }
}

-(void)addShip:(DockShip*)ship
{
    [self.tableView beginUpdates];
    DockEquippedShip* es = [DockEquippedShip equippedShipWithShip: ship];
    [_squad addEquippedShip: es];
    [self.navigationController popViewControllerAnimated: YES];
    NSError* error;

    if (![_squad.managedObjectContext save: &error]) {
        /*
           Replace this implementation with code to handle the error appropriately.

           abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    NSIndexPath* newShipIndexPath = [NSIndexPath indexPathForRow: _squad.equippedShips.count - 1 inSection: 1];
    [self.tableView insertRowsAtIndexPaths: @[newShipIndexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self updateCost];
}

-(void)addResource:(DockResource*)resource
{
    [self.navigationController popViewControllerAnimated: YES];
    _squad.resource = resource;
    NSError* error;

    if (!saveItem(_squad,  &error)) {
        presentError(error);
    }

    [self.tableView reloadData];
}

-(IBAction)export:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;

        [picker setSubject: [NSString stringWithFormat: @"Space Dock squad %@", _squad.name]];

        // Fill out the email body text
        NSString* textFormat = [_squad asPlainTextFormat];
        [picker setMessageBody: textFormat isHTML: NO];

        NSDictionary* json = [_squad asJSON];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject: json options: NSJSONWritingPrettyPrinted error: nil];
        [picker addAttachmentData: jsonData mimeType: @"text/x-spacedock" fileName: [_squad.name stringByAppendingPathExtension: kSpaceDockSquadFileExtension]];

        [self presentViewController: picker animated: YES completion: NULL];
    } else {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle: @"Can't send Squad"
                                                       message: @"This device is not configured to send mail."
                                                      delegate: nil
                                             cancelButtonTitle: nil
                                             otherButtonTitles: @"",
                             nil];
        [view show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (error != nil) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle: @"Can't send Squad"
                                                       message: error.localizedDescription
                                                      delegate: nil
                                             cancelButtonTitle: nil
                                             otherButtonTitles: @"",
                             nil];
        [view show];
    }

    [self dismissViewControllerAnimated: YES completion: NULL];
}

-(void)messageComposeViewController:(MFMessageComposeViewController*)controller
                didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated: YES completion: NULL];
}

-(void)duplicate
{
    DockSquad* squad = [_squad duplicate];
    NSError* error;

    if (!saveItem(squad, &error)) {
        presentError(error);
    }

    [self.navigationController popViewControllerAnimated: YES];
}

-(void)copyToClipboard
{
    NSString* plainText = [_squad asPlainTextFormat];
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = plainText;
}

-(IBAction)copy:(id)sender
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: @"Copy Squad"
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                         destructiveButtonTitle: nil
                                              otherButtonTitles: @"Duplicate", @"Copy to Clipboard",
                            nil];
    [sheet showFromBarButtonItem: _cpyBarItem animated: YES];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
    case 0:
        [self duplicate];
        break;

    case 1:
        [self copyToClipboard];
        break;
    }
}

-(IBAction)print:(id)sender
{
    NSMutableData* pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    UIGraphicsBeginPDFPage();
    CGRect pageBounds = UIGraphicsGetPDFContextBounds();
    CGRect blackBox = CGRectMake(0, 0, pageBounds.size.width, 100);
    [[UIColor blackColor] set];
    UIBezierPath* blackBoxPath = [UIBezierPath bezierPathWithRect: blackBox];
    [blackBoxPath fill];
    UIGraphicsEndPDFContext();
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if(!controller){
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
        }
    };
    
    
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
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
    controller.printingItem = pdfData;
    [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
}

@end
