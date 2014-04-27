#import "DockShip+Viper.h"

#import "DockShip+MacAddons.h"
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
    return styledAttack(self);
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
