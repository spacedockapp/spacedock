#import "DockWeapon+Addons.h"

#import "DockUpgrade+Addons.h"
#import "DockUtils.h"
#import "DockWeaponRange.h"

@implementation DockWeapon (Addons)

-(DockWeaponRange*)weaponRange
{
    return [[DockWeaponRange alloc] initWithString: self.range];
}

-(NSString*)rangeAsString
{
    return self.range;
}

@end
