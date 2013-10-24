#import "DockTopMenuViewController.h"
#import "DockShipsViewController.h"

@interface DockTopMenuViewController ()

@end

@implementation DockTopMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"GoToShips"]) {
        id destination = [segue destinationViewController];
        DockShipsViewController *shipsViewController = (DockShipsViewController *)destination;
        shipsViewController.managedObjectContext = self.managedObjectContext;
    }  else if ([[segue identifier] isEqualToString:@"ShowSelectedBook"]) {
        #if 0
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Book *selectedBook = (Book *)[[self fetchedResultsController] objectAtIndexPath:indexPath];

        // Pass the selected book to the new view controller.
        DetailViewController *detailViewController = (DetailViewController *)[segue destinationViewController];
        detailViewController.book = selectedBook;
        #endif
    }    
}

@end
