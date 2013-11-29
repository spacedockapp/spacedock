#import "DockSetTableViewCell.h"

@implementation DockSetTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];

    if (self) {
        // Initialization code
    }

    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected: selected animated: animated];

    if (selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }

    self.contentView.backgroundColor = [UIColor whiteColor];
    self.textLabel.textColor = [UIColor blackColor];
}

@end
