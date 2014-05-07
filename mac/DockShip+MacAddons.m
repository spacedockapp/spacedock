#import "DockShip+MacAddons.h"

#import "DockShip+Addons.h"
#import "DockUtilsMac.h"

@implementation DockShip (MacAddons)

-(NSAttributedString*)styledDescription
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: [self plainDescription]];
    NSAttributedString* space = [[NSAttributedString alloc] initWithString: @" "];
    [desc appendAttributedString: space];
    [desc appendAttributedString: [self styledAttack]];
    [desc appendAttributedString: space];
    [desc appendAttributedString: [self styledAgility]];
    [desc appendAttributedString: space];
    [desc appendAttributedString: [self styledHull]];
    [desc appendAttributedString: space];
    [desc appendAttributedString: [self styledShield]];
    return desc;
}


NSAttributedString* styledAttack(NSString* v)
{
    return makeCentered(coloredString(v, [NSColor whiteColor], [NSColor redColor]));
}

-(NSAttributedString*)styledAttack
{
    return styledAttack([[self attack] stringValue]);
}

NSAttributedString* styledAgility(NSString* v)
{
    return makeCentered(coloredString(v, [NSColor darkGrayColor], [NSColor greenColor]));
}

-(NSAttributedString*)styledAgility
{
    return styledAgility([[self agility] stringValue]);
}

NSAttributedString* styledHull(NSString* v)
{
    return makeCentered(coloredString(v, [NSColor darkGrayColor], [NSColor yellowColor]));
}

-(NSAttributedString*)styledHull
{
    if ([self isFighterSquadron]) {
        return styledHull(@"*");
    }
    return styledHull([[self hull] stringValue]);
}

NSAttributedString* styledShield(NSString* v)
{
    return makeCentered(coloredString(v, [NSColor whiteColor], [NSColor blueColor]));
}

-(NSAttributedString*)styledShield
{
    return styledShield([[self shield] stringValue]);
}

extern NSString* toString(int v)
{
    return [NSString stringWithFormat: @"%d", v];
}

@end
