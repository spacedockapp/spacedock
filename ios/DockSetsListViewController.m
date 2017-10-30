#import "DockSetsListViewController.h"
#import "DockUpgrade+Addons.h"
#import "DockShip+Addons.h"
#import "DockResource+Addons.h"
#import "DockSet+Addons.h"
#import "DockSetTableViewCell.h"
#import "DockUtilsMobile.h"

@interface DockSetsListViewController ()
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
//@property (strong, nonatomic) DockSet* targetSet;
@end

@implementation DockSetsListViewController

-(void)viewDidLoad
{
    self.cellIdentifer = @"Set";
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSArray* items = [self.fetchedResultsController fetchedObjects];

    for (DockSet* set in items) {
        if ([set.include boolValue]) {
            NSIndexPath* indexPath = [self.fetchedResultsController indexPathForObject: set];
            [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionNone];
        }
    }
    
    if ([DockSet includedSets:self.managedObjectContext].count > 0) {
        self.selectNone.enabled = YES;
    } else {
        self.selectNone.enabled = NO;
    }
    
    if ([DockSet includedSets:self.managedObjectContext].count == [DockSet allSets:self.managedObjectContext].count ) {
        self.selectAll.enabled = NO;
    } else {
        self.selectAll.enabled = YES;
    }

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    self.targetSet = nil;
    [super viewWillAppear: animated];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSString*)entityName
{
    return @"Set";
}

-(NSString*)sectionNameKeyPath
{
    return @"releaseDate";
}

-(BOOL)useSetFilter
{
    return NO;
}

-(void)setupFetch:(NSFetchRequest*)fetchRequest context:(NSManagedObjectContext*)context
{
    [super setupFetch: fetchRequest context: context];
}

-(NSArray*)sortDescriptors
{
    NSSortDescriptor* releaseDateDescriptor = [[NSSortDescriptor alloc] initWithKey: @"releaseDate" ascending: NO];
    NSSortDescriptor* titleDescriptor = [[NSSortDescriptor alloc] initWithKey: @"productName" ascending: YES];
    NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES];
    return @[releaseDateDescriptor, nameDescriptor, titleDescriptor];
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    DockSet* set = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.detailTextLabel.text = set.name;
    cell.textLabel.text = set.productName;
}

-(void)setIncludeSet:(DockSet*)set shouldInclude:(BOOL)shouldInclude
{
    NSError* error;
    set.include = [NSNumber numberWithBool: shouldInclude];

    if (!saveItem(set, &error)) {
        presentError(error);
    }
    
    if ([DockSet includedSets:self.managedObjectContext].count > 0) {
        self.selectNone.enabled = YES;
    } else {
        self.selectNone.enabled = NO;
    }
    
    if ([DockSet includedSets:self.managedObjectContext].count == [DockSet allSets:self.managedObjectContext].count ) {
        self.selectAll.enabled = NO;
    } else {
        self.selectAll.enabled = YES;
    }
}

-(IBAction)selectAll:(id)sender
{
    NSArray* allSets = [DockSet allSets:self.managedObjectContext];
    NSError* error;

    for (DockSet* s in allSets) {
        s.include = [NSNumber numberWithBool:YES];
    }

    if (![self.managedObjectContext save:&error]) {
        presentError(error);
    }
    [self.tableView reloadData];
    for (DockSet* s in allSets) {
        if ([s.include boolValue]) {
            NSIndexPath* indexPath = [self.fetchedResultsController indexPathForObject: s];
            [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition: UITableViewScrollPositionNone];
        }
    }
    self.selectAll.enabled = NO;
    self.selectNone.enabled = YES;
}

-(IBAction)selectNone:(id)sender
{
    NSArray* allSets = [DockSet allSets:self.managedObjectContext];
    NSError* error;
    
    for (DockSet* s in allSets) {
        s.include = [NSNumber numberWithBool:NO];
    }
    
    if (![self.managedObjectContext save:&error]) {
        presentError(error);
    }
    [self.tableView reloadData];
    self.selectNone.enabled = NO;
    self.selectAll.enabled = YES;
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        self.targetSet = nil;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        DockSet* set = [self.fetchedResultsController objectAtIndexPath: indexPath];
        self.targetSet = set;
        NSSet* items = [set items];
        NSUInteger upgrades = [[[items objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return [[obj class] isSubclassOfClass:[DockUpgrade class]];
        }] allObjects] count];
        NSUInteger ships = [[[items objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return [[obj class] isSubclassOfClass:[DockShip class]];
        }] allObjects] count];
        NSUInteger resources = [[[items objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return [[obj class] isSubclassOfClass:[DockResource class]];
        }] allObjects] count];
        if (upgrades > 0) {
            [self performSegueWithIdentifier:@"UpgradeList" sender:self];
        } else if (ships > 0) {
            [self performSegueWithIdentifier:@"ShipList" sender:self];
        } else if (resources > 0) {
            [self performSegueWithIdentifier:@"ResourceList" sender:self];
        } else {
            self.targetSet = nil;
        }
    }
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSIndexPath* firstObjectIndex = [NSIndexPath indexPathForRow: 0 inSection: section];
    DockSet* set = [self.fetchedResultsController objectAtIndexPath: firstObjectIndex];
    NSString* releaseDate = [self.dateFormatter stringFromDate: set.releaseDate];
    return [NSString stringWithFormat:@"%@ - %@", releaseDate, set.name];
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DockSet* set = [self.fetchedResultsController objectAtIndexPath: indexPath];
    [self setIncludeSet: set shouldInclude: YES];
}

-(void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DockSet* set = [self.fetchedResultsController objectAtIndexPath: indexPath];
    [self setIncludeSet: set shouldInclude: NO];
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString: @"UpgradeList"]) {
        id destination = [segue destinationViewController];
        DockTableViewController* controller = (DockTableViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.targetSet = self.targetSet;
        controller.title = @"Upgrades";
    } else if ([[segue identifier] isEqualToString: @"ShipList"]) {
        id destination = [segue destinationViewController];
        DockTableViewController* controller = (DockTableViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.targetSet = self.targetSet;
        controller.title = @"Ships";
    } else if ([[segue identifier] isEqualToString: @"ResourceList"]) {
        id destination = [segue destinationViewController];
        DockTableViewController* controller = (DockTableViewController*)destination;
        controller.managedObjectContext = self.managedObjectContext;
        controller.targetSet = self.targetSet;
        controller.title = @"Resources";
    }
}

@end
