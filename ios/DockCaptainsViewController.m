#import "DockCaptainsViewController.h"

#import "DockCaptain+Addons.h"

@interface DockCaptainsViewController ()

@end

@implementation DockCaptainsViewController

- (void)viewDidLoad
{
    self.cellIdentifer = @"Captain";
    [super viewDidLoad];
}

-(NSString*)entityName
{
    return @"Captain";
}

#pragma mark - Table view data source methods

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    DockCaptain *captain = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = captain.title;
}

@end
