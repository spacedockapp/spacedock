#import "DockFlagshipDetailViewController.h"

@interface DockFlagshipDetailViewController ()

@end

@implementation DockFlagshipDetailViewController

-(NSArray*)attributeNamesToDisplay
{
    return @[@"name", @"attack", @"agility", @"hull", @"shield", @"capabilities", @"ability"];
}

@end
