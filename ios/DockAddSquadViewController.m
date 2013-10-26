#import "DockAddSquadViewController.h"

@interface DockAddSquadViewController ()

@end

@implementation DockAddSquadViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
}


- (IBAction)cancel:(id)sender
{
    [self.delegate addSquadViewController:self didFinishWithSave:NO];
}


- (IBAction)save:(id)sender
{    
    [self.delegate addSquadViewController:self didFinishWithSave:YES];
}


- (void)dealloc
{
}


@end
