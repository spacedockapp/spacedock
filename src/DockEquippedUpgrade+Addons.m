#import "DockEquippedUpgrade+Addons.h"

#import "DockEquippedUpgrade.h"
#import "DockUpgrade+Addons.h"
#import "DockUpgrade.h"

@implementation DockEquippedUpgrade (Addons)

-(NSString*)title
{
    return self.upgrade.title;
}

-(NSString*)description
{
    return self.upgrade.description;
}

-(NSArray*)sortedUpgrades
{
    return nil;
}

-(NSComparisonResult)compareTo:(DockEquippedUpgrade*)other
{

    return [[self upgrade] compareTo: [other upgrade]];
}


@end
