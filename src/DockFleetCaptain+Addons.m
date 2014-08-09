#import "DockFleetCaptain+Addons.h"

#import "DockResource+Addons.h"
#import "DockConstants.h"

@implementation DockFleetCaptain (Addons)

-(NSString*)upType
{
    return kFleetCaptainUpgradeType;
}

-(NSString*)formattedCaptainSkillBonus
{
    int skillBonus = [[self captainSkillBonus] intValue];
    return [NSString stringWithFormat: @"+%d", skillBonus];
}

-(int)additionalWeaponSlots
{
    return [[self weaponAdd] intValue];
}

-(int)additionalTechSlots
{
    return [[self techAdd] intValue];
}

-(int)additionalCrewSlots
{
    return [[self crewAdd] intValue];
}

-(int)additionalTalentSlots
{
    return [[self talentAdd] intValue];
}

-(DockResource*)associatedResource
{
    return [DockResource resourceForId: @"fleet_captain_collectiveop2" context: self.managedObjectContext];
}

-(int)costToInstall
{
    return 5;
}

-(int)costForShip:(DockEquippedShip*)equippedShip
{
    return 5;
}

@end
