#import "DockShip+MacAddons.h"

#import "DockUtils.h"

@implementation DockShip (MacAddons)

NSAttributedString* styledAttack(id ship)
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([[ship attack] stringValue], [NSColor whiteColor], [NSColor redColor]))];
    return desc;
}

-(NSAttributedString*)styledAttack
{
    return styledAttack(self);
}

NSAttributedString* styledAgility(id ship)
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([[ship agility] stringValue], [NSColor darkGrayColor], [NSColor greenColor]))];
    return desc;
}

-(NSAttributedString*)styledAgility
{
    return styledAgility(self);
}

NSAttributedString* styledHull(id ship)
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([[ship hull] stringValue], [NSColor darkGrayColor], [NSColor yellowColor]))];
    return desc;
}

-(NSAttributedString*)styledHull
{
    return styledHull(self);
}

NSAttributedString* styledShield(id ship)
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([[ship shield] stringValue], [NSColor whiteColor], [NSColor blueColor]))];
    return desc;
}

-(NSAttributedString*)styledShield
{
    return styledShield(self);
}

@end
