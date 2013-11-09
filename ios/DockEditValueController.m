#import "DockEditValueController.h"

@interface DockEditValueController ()
@end

@implementation DockEditValueController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_valueField setText: _initialValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setValueName:(NSString *)valueName
{
    [self setTitle: valueName];
}

-(void)setInitialValue:(NSString *)initialValue
{
    _initialValue = initialValue;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

-(IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)save:(id)sender
{
    if (_onSave != nil) {
        _onSave([_valueField text]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
