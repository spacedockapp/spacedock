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

-(NSString*)capabilities
{
    NSMutableArray* caps = [[NSMutableArray alloc] initWithCapacity: 0];
    int v = [self additionalTechSlots];

    if (v > 0) {
        [caps addObject: [NSString stringWithFormat: @"Tech: %d", v]];
    }

    v = [self additionalWeaponSlots];

    if (v > 0) {
        [caps addObject: [NSString stringWithFormat: @"Weapon: %d", v]];
    }

    v = [self additionalCrewSlots];

    if (v > 0) {
        [caps addObject: [NSString stringWithFormat: @"Crew: %d", v]];
    }

    v = [self additionalTalentSlots];

    if (v > 0) {
        [caps addObject: [NSString stringWithFormat: @"Talent: %d", v]];
    }

    return [[caps sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)] componentsJoinedByString: @" "];
}

-(NSString*)titleForPlainTextFormat
{
    return [NSString stringWithFormat: @"Fleet Captain: %@", self.title];
}

@end
