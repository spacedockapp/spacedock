#import "DockBuildSheetView.h"

#import "DockBuildSheetRenderer.h"

@interface DockBuildSheetView ()
@property (strong, nonatomic) DockBuildSheetRenderer* renderer;
@end

@implementation DockBuildSheetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    _renderer = [[DockBuildSheetRenderer alloc] initWithSquad: _squad];
}

- (void)drawRect:(CGRect)rect
{
    [_renderer draw: self.bounds];
}

-(void)setSquad:(DockSquad *)squad
{
    _squad = squad;
    _renderer = [[DockBuildSheetRenderer alloc] initWithSquad: _squad];
    [self setNeedsDisplay];
}

@end
