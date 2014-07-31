#import "DockSearchFieldController.h"

@interface DockSearchFieldController () <NSTextFieldDelegate>
@property (assign, nonatomic) IBOutlet NSSearchFieldCell* searchField;
@end

NSString* kCurrentSearchTerm = @"CurrentSearchTerm";

@implementation DockSearchFieldController

- (IBAction)updateFilter:sender
{
    NSString *searchString = [_searchField stringValue];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    NSNotification* notification = [NSNotification notificationWithName: kCurrentSearchTerm object: searchString];
    [center postNotification: notification];
}

-(void)clear
{
    NSString *searchString = [_searchField stringValue];
    NSString* clearedValue = @"";
    if (![searchString isEqualToString: clearedValue]) {
        [_searchField setStringValue: clearedValue];
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        NSNotification* notification = [NSNotification notificationWithName: kCurrentSearchTerm object: clearedValue];
        [center postNotification: notification];
    }
}

-(BOOL)hasSearchTerm
{
    NSString *searchString = [_searchField stringValue];
    return searchString.length > 0;
}


@end
