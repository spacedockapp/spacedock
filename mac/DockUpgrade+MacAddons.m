#import "DockUpgrade+MacAddons.h"

#import "DockUpgrade+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip+MacAddons.h"
#import "DockSquad+Addons.h"
#import "DockUtilsMac.h"

@implementation DockUpgrade (MacAddons)

-(NSAttributedString*)formattedAttack
{
    return nil;
}

-(int)attackValue
{
    return 0;
}

-(NSAttributedString*)styledDescription
{
    NSString* s = [self plainDescription];

    if ([self isPlaceholder]) {
        NSMutableAttributedString* as = [[NSMutableAttributedString alloc] initWithString: s];
        NSRange r = NSMakeRange(0, s.length);
        [as applyFontTraits: NSItalicFontMask range: r];
        return as;
    }

    return [[NSAttributedString alloc] initWithString: s];
}

-(BOOL)canInstallIntoTargetShip
{
    DockEquippedShip* targetShip = [DockEquippedShip currentTargetShip];
    if (targetShip == nil) {
        return YES;
    }
    if (![targetShip canAddUpgrade: self]) {
        return NO;
    }
    DockEquippedUpgrade* existing = [targetShip.squad containsUpgradeWithName: self.title];
    return existing == nil;
}

-(NSAttributedString*)titleWithCanInstall
{
    NSString* dt = [self title];
    if (![self canInstallIntoTargetShip]) {
        return coloredString(dt, [NSColor grayColor], [NSColor clearColor]);
    }
    return [[NSAttributedString alloc] initWithString: dt];
}

-(int)costToInstall
{
    DockEquippedShip* targetShip = [DockEquippedShip currentTargetShip];
    if (targetShip == nil) {
        return [self.cost intValue];
    }
    if (![targetShip canAddUpgrade: self]) {
        return INT_MAX;
    }
    return [self costForShip: targetShip];
}

-(NSAttributedString*)styledCostToInstall
{
    DockEquippedShip* targetShip = [DockEquippedShip currentTargetShip];
    if (targetShip == nil) {
        NSString* costString = [NSString stringWithFormat: @"%@", self.cost];
        return [[NSAttributedString alloc] initWithString: costString];
    }
    if (![targetShip canAddUpgrade: self]) {
        return makeCentered([[NSAttributedString alloc] initWithString: @"n/a"]);
    }
    int baseCost = [[self cost] intValue];
    int costForShip = [self costToInstall];
    NSString* costString = [NSString stringWithFormat: @"%d", costForShip];

    if (baseCost == costForShip) {
        return makeCentered([[NSAttributedString alloc] initWithString: costString]);
    }

    if (baseCost > costForShip) {
        return makeCentered(coloredString(costString, [NSColor greenColor], [NSColor clearColor]));
    }

    return makeCentered(coloredString(costString, [NSColor redColor], [NSColor clearColor]));
}

@end
