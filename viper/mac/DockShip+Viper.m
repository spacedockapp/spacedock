#import "DockShip+Viper.h"

#import "DockShip+MacAddons.h"
#import "DockUtilsMac.h"
#import "DockWeaponRange.h"

@implementation DockShip (Viper)

-(DockWeaponRange*)shipWeaponRange
{
    return [[DockWeaponRange alloc] initWithString: self.shipRange];
}

-(DockWeaponRange*)craftWeaponRange
{
    return [[DockWeaponRange alloc] initWithString: self.craftRange];
}

-(NSAttributedString*)styledCraftAttack
{
    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: @""];
    [desc appendAttributedString: makeCentered(coloredString([[self craftAttack] stringValue], [NSColor whiteColor], [NSColor redColor]))];
    return desc;
}

-(NSString*)plainDescription
{
    return self.title;
}

-(NSString*)descriptiveTitle
{
    return self.title;
}

@end
