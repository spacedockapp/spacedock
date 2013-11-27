#import "DockMovesViewController.h"

#import "DockMoveGridView.h"

@interface DockMovesViewController ()

@end

@implementation DockMovesViewController

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
    _moveGrid.ship = _ship;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
