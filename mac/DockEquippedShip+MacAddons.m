#import "DockEquippedShip+MacAddons.h"

#import "DockEquippedShip+Addons.h"
#import "DockResource+Addons.h"
#import "DockShip+MacAddons.h"
#import "DockSquad+Addons.h"
#import "DockUtilsMac.h"

@implementation DockEquippedShip (MacAddons)

static  NSValue* sCurrentTargetShip = nil;

NSString* kCurrentTargetShipChanged = @"DockCurrentTargetShipChanged";

+(DockEquippedShip*)currentTargetShip
{
    return [sCurrentTargetShip nonretainedObjectValue];
}

+(void)setCurrentTargetShip:(DockEquippedShip*)targetShip
{
    if (targetShip == nil) {
        sCurrentTargetShip = nil;
    } else {
        sCurrentTargetShip = [NSValue valueWithNonretainedObject: targetShip];
    }
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    NSNotification* notification = [NSNotification notificationWithName: kCurrentTargetShipChanged object: nil];
    [center postNotification: notification];
}

+(void)clearCurrentTargetShip
{
    [self setCurrentTargetShip: nil];
    sCurrentTargetShip = nil;
}

-(NSAttributedString*)styledDescription
{
    if ([self isResourceSideboard]) {
        return [[NSAttributedString alloc] initWithString: self.squad.resource.title];
    }

    NSMutableAttributedString* desc = [[NSMutableAttributedString alloc] initWithString: [self plainDescription]];
    NSAttributedString* space = [[NSAttributedString alloc] initWithString: @" "];
    [desc appendAttributedString: space];
    [desc appendAttributedString: styledAttack(toString([self attack]))];
    [desc appendAttributedString: space];
    [desc appendAttributedString: styledAgility(toString([self agility]))];
    [desc appendAttributedString: space];
    [desc appendAttributedString: styledHull(toString([self hull]))];
    [desc appendAttributedString: space];
    [desc appendAttributedString: styledShield(toString([self shield]))];
    return desc;
}

-(NSAttributedString*)formattedCost
{
    NSString* costString = [NSString stringWithFormat: @"%d", self.cost];
    return coloredString(costString, [NSColor textColor], [NSColor clearColor]);
}

-(NSAttributedString*)styledAttack
{
    return styledAttack([self attackString]);
}

-(NSAttributedString*)styledAgility
{
    return styledAgility([self agilityString]);
}

-(NSAttributedString*)styledHull
{
    if ([self isFighterSquadron]) {
        return styledHull(@"*");
    }
    return styledHull([self hullString]);
}

-(NSAttributedString*)styledShield
{
    return styledShield([self shieldString]);
}

@end
