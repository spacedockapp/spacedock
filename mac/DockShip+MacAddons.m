#import "DockShip+MacAddons.h"

#import "DockShip+Addons.h"
#import "DockUtilsMac.h"

@implementation DockShip (MacAddons)

-(NSAttributedString*)styledDescription
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: [self plainDescription]];
    NSAttributedString* space = [[NSAttributedString alloc] initWithString: @" "];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.attack stringValue], [NSColor whiteColor], [NSColor redColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.agility stringValue], [NSColor blackColor], [NSColor greenColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.hull stringValue], [NSColor blackColor], [NSColor yellowColor])];
    [desc appendAttributedString: space];
    [desc appendAttributedString: coloredString([self.shield stringValue], [NSColor whiteColor], [NSColor blueColor])];
    return desc;
}


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
    if (![ship isFighterSquadron]) {
        [desc appendAttributedString: makeCentered(coloredString([[ship hull] stringValue], [NSColor darkGrayColor], [NSColor yellowColor]))];
    }
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
