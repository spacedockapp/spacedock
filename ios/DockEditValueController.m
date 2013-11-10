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
