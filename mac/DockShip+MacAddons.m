#import "DockShip+MacAddons.h"

#import "DockUtils.h"

@implementation DockShip (MacAddons)

-(NSAttributedString*)styledAttack
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([self.attack stringValue], [NSColor whiteColor], [NSColor redColor]))];
    return desc;
}

-(NSAttributedString*)styledAgility
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([self.agility stringValue], [NSColor blackColor], [NSColor greenColor]))];
    return desc;
}

-(NSAttributedString*)styledHull
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([self.hull stringValue], [NSColor blackColor], [NSColor yellowColor]))];
    return desc;
}

-(NSAttributedString*)styledShield
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([self.shield stringValue], [NSColor whiteColor], [NSColor blueColor]))];
    return desc;
}

@end
