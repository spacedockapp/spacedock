#import "DockSquadDetailController.h"

#import "DockBuildSheetViewController.h"
#import "DockConstants.h"
#import "DockEditNotesCell.h"
#import "DockEditStringTableCell.h"
#import "DockEditValueController.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShipCell.h"
#import "DockEquippedShipController.h"
#import "DockResource+Addons.h"
#import "DockResourcesViewController.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipsViewController.h"
#import "DockSquad+Addons.h"
#import "DockSquadsListController.h"
#import "DockUtilsMobile.h"
#import "DockUpgrade+Addons.h"

#import <MessageUI/MessageUI.h>

enum {
    kNameRow, kCostRow, kResourceRow, kResourceAttributesRow, kSectionOneCount
};

enum {
    kAdditionalPointsRow, kNotesRow, kSectionThreeCount
};

enum {
    kDetailsSection, kShipsSection, kNotesSection, kSectionCount
};

@interface DockSquadDetailController ()<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) IBOutlet UIBarButtonItem* cpyBarItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* printBarItem;
@property (assign, nonatomic) int targetRow;
@property (assign, nonatomic) id oldTarget;
@property (assign, nonatomic) SEL oldAction;
@property (nonatomic, strong) NSString* fleetCostHighlight;
@property (nonatomic, assign) BOOL mark50spShip;
@property (nonatomic, assign) BOOL markExpiredRes;

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
    _oldTarget = _printBarItem.target;
    _oldAction = _printBarItem.action;
    if (!isOS7OrGreater()) {
        [_printBarItem setAction: @selector(explainCantPrint:)];
        [_printBarItem setTarget: self];
    }
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _fleetCostHighlight = [defaults stringForKey: @"fleetCostHighlight"];
    _mark50spShip = [defaults boolForKey: @"mark50spShip"];
    _markExpiredRes = [defaults boolForKey:kMarkExpiredResKey];
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
    [self updateCost];
    [_squad addObserver: self forKeyPath: @"cost" options: 0 context: 0];
}

-(void)validatePrinting
{
    if (isOS7OrGreater()) {
        if (_squad.equippedShips.count > 10) {
            [_printBarItem setAction: @selector(explainCantPrintThisSquad:)];
            [_printBarItem setTarget: self];
        } else if ([_squad flagshipIsNotAssigned]) {
            [_printBarItem setAction: @selector(explainNeedToAssignFlagship:)];
            [_printBarItem setTarget: self];
        } else {
            [_printBarItem setAction: _oldAction];
            [_printBarItem setTarget: _oldTarget];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self validatePrinting];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_squad removeObserver: self forKeyPath: @"cost"];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return kSectionCount;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kDetailsSection) {
        return @"Details";
    }

    if (section == kNotesSection) {
        return @"Notes and Extra Points";
    }

    return @"Ships";
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kDetailsSection) {
        if (_squad.resourceAttributes.length == 0) {
            return kSectionOneCount - 1;
        } else {
            return kSectionOneCount;
        }
    }

    if (section == kNotesSection) {
        return kSectionThreeCount;
    }

    return _squad.equippedShips.count + 1;
}

- (UITableViewCell *)cellForDetails:(NSIndexPath *)indexPath tableView:(UITableView *)tableView row:(NSInteger)row
{
    UITableViewCell *cell;
    if (self.tableView.editing && row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier: @"editDetail" forIndexPath: indexPath];
        DockEditStringTableCell* editCell = (DockEditStringTableCell*)cell;
        editCell.labelField.text = @"Name";
        editCell.valueField.text = _squad.name;
        editCell.valueField.delegate = self;
        editCell.valueField.keyboardType = UIKeyboardTypeDefault;
        editCell.valueField.tag = 0;
    } else {
        if (row == kResourceRow) {
            cell = [tableView dequeueReusableCellWithIdentifier: @"resource" forIndexPath: indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier: @"detail" forIndexPath: indexPath];
        }
        
        if (row == kNameRow) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = _squad.name;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.textColor = [UIColor blackColor];
        } else if (row == kCostRow) {
            cell.textLabel.text = @"Cost";
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", _squad.cost];
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (![_fleetCostHighlight isEqualToString:@"None"]) {
                int cost = [_squad cost];
                
                if ([_fleetCostHighlight isEqualToString:@"90/130"]) {
                    if ((cost > 90 && cost < 110) || cost > 130) {
                        cell.detailTextLabel.textColor = [UIColor redColor];
                    } else {
                        cell.detailTextLabel.textColor = [UIColor blackColor];
                    }
                } else if ([_fleetCostHighlight isEqualToString:@"90/120"]) {
                    if ((cost > 90 && cost < 110) || cost > 120) {
                        cell.detailTextLabel.textColor = [UIColor redColor];
                    } else {
                        cell.detailTextLabel.textColor = [UIColor blackColor];
                    }
                } else if ([_fleetCostHighlight isEqualToString:@"100"]) {
                    if (cost > 100) {
                        cell.detailTextLabel.textColor = [UIColor redColor];
                    } else {
                        cell.detailTextLabel.textColor = [UIColor blackColor];
                    }
                } else if ([_fleetCostHighlight isEqualToString:@"120"]) {
                    if (cost > 120) {
                        cell.detailTextLabel.textColor = [UIColor redColor];
                    } else {
                        cell.detailTextLabel.textColor = [UIColor blackColor];
                    }
                } else if ([_fleetCostHighlight isEqualToString:@"200"]) {
                    if (cost > 200) {
                        cell.detailTextLabel.textColor = [UIColor redColor];
                    } else {
                        cell.detailTextLabel.textColor = [UIColor blackColor];
                    }
                }
            }
        } else if (row == kResourceAttributesRow) {
            cell.textLabel.text = @"Factions";
            cell.detailTextLabel.text = _squad.resourceAttributes;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.textLabel.text = @"Resource";
            
            if (_squad.resource != nil) {
                cell.detailTextLabel.text = _squad.resource.title;
                if (_markExpiredRes) {
                    DockSet* set = [_squad.resource.sets anyObject];
                    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    NSDateComponents *components = [cal components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:set.releaseDate];
                    [components setDay:1];
                    
                    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                                       components:NSCalendarUnitMonth
                                                       fromDate:[cal dateFromComponents:components]
                                                       toDate:[NSDate date] options:0];
                    if (ageComponents.month >= 18) {
                        NSMutableAttributedString* as = cell.detailTextLabel.attributedText.mutableCopy;
                        NSMutableAttributedString* exp = [[NSMutableAttributedString alloc] initWithString:@" (Retired)"];
                        [exp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[exp length])];
                        [as appendAttributedString:exp];
                        cell.detailTextLabel.attributedText = as;
                    } else if (ageComponents.month == 17) {
                        NSMutableAttributedString* as = cell.detailTextLabel.attributedText.mutableCopy;
                        NSMutableAttributedString* exp = [[NSMutableAttributedString alloc] initWithString:@" (Retiring)"];
                        [exp addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0,[exp length])];
                        [as appendAttributedString:exp];
                        cell.detailTextLabel.attributedText = as;
                    }
                }
            } else {
                cell.detailTextLabel.text = @"No Resource";
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

- (UITableViewCell *)cellForNotes:(NSIndexPath *)indexPath tableView:(UITableView *)tableView row:(NSInteger)row
{
    UITableViewCell *cell;
    if (row == kNotesRow) {
        cell = [tableView dequeueReusableCellWithIdentifier: @"editNotes" forIndexPath: indexPath];
        DockEditNotesCell* editCell = (DockEditNotesCell*)cell;
        editCell.labelField.text = @"Notes";
        UITextView* notesView = editCell.notesView;
        notesView.text = _squad.notes;
        notesView.delegate = self;
        notesView.editable = self.tableView.editing;
        if (isOS7OrGreater()) {
            notesView.textContainerInset = UIEdgeInsetsZero;
        }
        CALayer* layer = notesView.layer;
        if (self.tableView.editing) {
            [layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
            [layer setBorderWidth: 0.5];
            layer.cornerRadius = 5;
            notesView.clipsToBounds = YES;
        } else {
            [layer setBorderWidth:0];
            layer.cornerRadius = 0;
            notesView.clipsToBounds = NO;
        }
    } else {
        if (row == kAdditionalPointsRow) {
            if (self.tableView.editing) {
                cell = [tableView dequeueReusableCellWithIdentifier: @"editDetail" forIndexPath: indexPath];
                DockEditStringTableCell* editCell = (DockEditStringTableCell*)cell;
                editCell.labelField.text = @"Extra Points";
                editCell.valueField.text = [NSString stringWithFormat: @"%d", [[_squad additionalPoints] intValue]];
                editCell.valueField.delegate = self;
                editCell.valueField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                editCell.valueField.tag = 0xdeadbeef;
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier: @"detail" forIndexPath: indexPath];
                cell.textLabel.text = @"Extra Points";
                cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", [[_squad additionalPoints] intValue]];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (UITableViewCell *)cellForShips:(NSInteger)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    UITableViewCell *cell;
    NSInteger shipCount = _squad.equippedShips.count;
    
    if (row == shipCount) {
        cell = [tableView dequeueReusableCellWithIdentifier: @"addShip" forIndexPath: indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier: @"ship" forIndexPath: indexPath];
        DockEquippedShipCell* shipCell = (DockEquippedShipCell*)cell;
        DockEquippedShip* es = _squad.equippedShips[row];
        shipCell.cost.text = [NSString stringWithFormat: @"%d", [es cost]];
        if (_mark50spShip && [es cost] > 50) {
            shipCell.cost.textColor = [UIColor redColor];
        } else {
            shipCell.cost.textColor = [UIColor blackColor];
        }
        shipCell.details.text = [es upgradesDescription];
        shipCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString* t = es.plainDescription;
        if (es.flagship) {
            t = [t stringByAppendingString: @" [FS]"];
        }
        shipCell.title.text = t;
    }
    return cell;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger row = [indexPath indexAtPosition: 1];
    UITableViewCell* cell = nil;

    if (section == kDetailsSection) {
        cell = [self cellForDetails:indexPath tableView:tableView row:row];
    } else if (section == kNotesSection) {
        cell = [self cellForNotes:indexPath tableView:tableView row:row];
    } else {
        cell = [self cellForShips:row indexPath:indexPath tableView:tableView];
    }

    return cell;
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger row = [indexPath indexAtPosition: 1];
    if (section == kShipsSection) {
        return row != _squad.equippedShips.count;
    } else if (section == kDetailsSection) {
        return row == kResourceRow && _squad.resource != nil;
    }
    return NO;
}

-(void)reloadResouce
{
    NSIndexPath* resourceIndexPath = [NSIndexPath indexPathForRow: 2 inSection: 0];
    [self.tableView reloadRowsAtIndexPaths: @[resourceIndexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
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
            
            if (resource.isFighterSquadron) {
                for (DockEquippedShip* es in _squad.equippedShips) {
                    if (es.isFighterSquadron) {
                        [_squad removeEquippedShip:es];
                    }
                }
                
                NSError* error;
                
                if (!saveItem(_squad, &error)) {
                    presentError(error);
                }

                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex: kShipsSection] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            if (_squad.resourceAttributes != nil) {
                NSIndexPath* resourceAttributesPath = [NSIndexPath indexPathForItem:kResourceAttributesRow inSection:kDetailsSection];
                if (resourceAttributesPath != nil) {
                    [self.tableView deleteRowsAtIndexPaths:@[resourceAttributesPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            _squad.resource = nil;
            
            _squad.resourceAttributes = nil;

            [self.tableView reloadRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
            
        }
    } else {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            DockEquippedShip* es = _squad.equippedShips[row];

            if (es.isResourceSideboard || es.isFighterSquadron) {
                _squad.resource = nil;
                [self reloadResouce];
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
    [self validatePrinting];
}

-(BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger row = [indexPath indexAtPosition: 1];

    if (section == kShipsSection) {
        NSInteger shipCount = _squad.equippedShips.count;
        return row < shipCount;
    }

    if (section == kDetailsSection) {
        return  row == kResourceRow;
    }

    return NO;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];

    if (section == kDetailsSection) {
        return 32;
    }
    
    if (section == kNotesSection) {
        NSInteger row = [indexPath indexAtPosition: 1];
        if (row == kAdditionalPointsRow) {
            return 32;
        }
        
        return 400;
    }

    return tableView.rowHeight;
}

#pragma mark - TextField

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 0xdeadbeef) {
        _squad.additionalPoints = [NSNumber numberWithInt: [textField.text intValue]];;
    } else {
        _squad.name = textField.text;
    }
    NSError* error;
    if (!saveItem(_squad, &error)) {
        presentError(error);
    }
}

#pragma mark - TextView

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _squad.notes = textView.text;
    NSError* error;
    if (!saveItem(_squad, &error)) {
        presentError(error);
    }
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    if ([identifier isEqualToString: @"EditName"]) {
        return NO;
    }
    return YES;
}

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
        switch (_targetRow) {
            case kAdditionalPointsRow:
                editValue.initialValue = [NSString stringWithFormat: @"%d", [_squad.additionalPoints intValue]];
                editValue.valueName = @"Additional Points";
                break;
            default:
                editValue.valueName = @"Name";
                editValue.initialValue = _squad.name;
                break;
        }
        
        editValue.onSave = ^(NSString* newValue) {
            switch (_targetRow) {
                case kAdditionalPointsRow:
                    _squad.additionalPoints = [NSNumber numberWithInt: [newValue intValue]];
                    break;
                    
                default:
                    _squad.name = newValue;
                    break;
            }
            NSError* error;

            if (!saveItem(_squad, &error)) {
                presentError(error);
            }

            [self.tableView reloadData];
        };
    } else if ([sequeIdentifier isEqualToString: @"EditPoints"]) {
        DockEditValueController* editValue = (DockEditValueController*)destination;
        editValue.valueName = @"Add. Points";
        editValue.initialValue = [NSString stringWithFormat: @"%d", [_squad.additionalPoints intValue]];;
        editValue.onSave = ^(NSString* newValue) {
            _squad.additionalPoints = [NSNumber numberWithInt: [newValue intValue]];
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
    if (ship.isFighterSquadron) {
        _squad.resource = ship.associatedResource;
        [self reloadResouce];
    } else {
        DockEquippedShip* es = [DockEquippedShip equippedShipWithShip: ship];
        [_squad addEquippedShip: es];
    }
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
    _squad.resourceAttributes = nil;
    NSError* error;

    if (!saveItem(_squad,  &error)) {
        presentError(error);
    }

    [self.tableView reloadData];

    if ([resource.externalId isEqualToString:@"officer_exchange_program_71996a"]) {
        _squad.resourceAttributes = @"";
        [self selectFactionSheet:1];
    }
}

-(void)selectFactionSheet:(int)factionN
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: [NSString stringWithFormat:@"Select Faction %d",factionN]
                                                       delegate: self
                                              cancelButtonTitle: nil
                                         destructiveButtonTitle: nil
                                              otherButtonTitles: nil];
    NSSet* factionsSet = [DockUpgrade allFactions: _squad.managedObjectContext];
    NSArray* factionsArray = [[factionsSet allObjects] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    for (NSString* faction in factionsArray) {
        if ([_squad.resourceAttributes rangeOfString:faction].location == NSNotFound) {
            [sheet addButtonWithTitle: faction];
        }
    }
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kResourceRow inSection:kDetailsSection]];
    if (cell != nil) {
        [sheet showFromRect:cell.frame inView:self.view animated:YES];
    } else {
        [sheet showFromRect:self.tableView.frame inView:self.view animated:YES];
    }
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
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles: nil];
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
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles: nil];
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

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:@"Select Faction 1"]) {
        NSString* faction = [actionSheet buttonTitleAtIndex:buttonIndex];
        _squad.resourceAttributes = faction;
        [self selectFactionSheet:2];
    } else if ([actionSheet.title isEqualToString:@"Select Faction 2"]) {
        NSString* faction = [actionSheet buttonTitleAtIndex:buttonIndex];
        _squad.resourceAttributes = [_squad.resourceAttributes stringByAppendingFormat:@" & %@",faction];
        NSError* error;
        
        if (!saveItem(_squad,  &error)) {
            presentError(error);
        }
        [self.tableView reloadData];
    } else {
        switch (buttonIndex) {
        case 0:
            [self duplicate];
            break;

        case 1:
            [self copyToClipboard];
            break;
        }
    }
}

- (IBAction)enterEditMode:(id)sender
{
    UIBarButtonItem* editButton = sender;
    if ([self.tableView isEditing]) {
        editButton.style = UIBarButtonItemStylePlain;
        editButton.title = @"Edit";
        [self.tableView setEditing: NO animated:YES];
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex: kDetailsSection] withRowAnimation: UITableViewRowAnimationFade];
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex: kNotesSection] withRowAnimation: UITableViewRowAnimationFade];
    } else {
        editButton.style = UIBarButtonItemStyleDone;
        editButton.title = @"Done";
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex: kDetailsSection] withRowAnimation: UITableViewRowAnimationFade];
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex: kNotesSection] withRowAnimation: UITableViewRowAnimationFade];
    }
}

- (IBAction)explainCantPrint:(id)sender
{
    presentUnsuppportedFeatureDialog();
}

- (IBAction)explainCantPrintThisSquad:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Can't Print"
                                                     message: kSquadTooLargeToPrint
                                                    delegate: nil
                                           cancelButtonTitle: @"OK"
                                           otherButtonTitles: nil];
    [alert show];
}

- (IBAction)explainNeedToAssignFlagship:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Can't Print"
                                                     message: kFlagshipPrintingError
                                                    delegate: nil
                                           cancelButtonTitle: @"OK"
                                           otherButtonTitles: nil];
    [alert show];
}

@end
