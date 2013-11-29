#import "DockResourceDetailViewController.h"

@interface DockResourceDetailViewController ()

@end

@implementation DockResourceDetailViewController

-(NSArray*)attributeNamesToDisplay
{
    return @[@"title", @"cost", @"ability"];
}

@end
