#import "DockCaptain+Addons.h"

#import "DockShip+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"

@implementation DockCaptain (Addons)

-(int)talentCount
{
    return [self.talent intValue];
}

+(DockUpgrade*)zeroCostCaptain:(NSString*)faction context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Captain" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"cost = 0 and faction like %@ and unique = 0", faction];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        if ((DockUpgrade*)existingItems[0] == [DockUpgrade upgradeForId:@"romulan_drone_pilot_71536" context:context]) {
            return existingItems[1];
        }
        return existingItems[0];
    }

    return nil;
}

+(DockUpgrade*)zeroCostCaptainForShip:(DockShip*)targetShip
{
    NSManagedObjectContext* context = targetShip.managedObjectContext;
    NSString* faction = targetShip.faction;
    NSSet* targetShipSets = targetShip.sets;
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Captain" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"cost = 0 and faction like %@", faction];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        for(DockCaptain* captain in existingItems) {
            NSSet* captainSets = captain.sets;
            if ([captainSets intersectsSet: targetShipSets] && ![captain isUnique]) {
                return captain;
            }
        }
        return existingItems[0];
    }

    return nil;
}

+(DockUpgrade*)captainForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    return [DockUpgrade upgradeForId: externalId context: context];
}

-(BOOL)isZeroCost
{
    return [self.cost intValue] == 0;
}

-(BOOL)isKirk
{
    return [self.externalId isEqualToString: @"2011"];
}

-(BOOL)isTholian
{
    return [self.externalId isEqualToString: @"tholian_opwebprize"] || [self.externalId isEqualToString: @"loskene_opwebprize"];
}

NSDictionary* sCaptainTechSlotAdds = nil;

-(int)additionalTechSlots
{
    NSString* special = self.special;
    if ([special isEqualToString: @"addonetechslot"] || [special isEqualToString: @"AddsHiddenTechSlot"]) {
        return 1;
    }

    if (sCaptainTechSlotAdds == nil) {
        sCaptainTechSlotAdds = @{
            @"calvin_hudson_b_71528": @1,
            @"jean_luc_picard_b_71531": @1,
        };
    }

    NSString* externalId = self.externalId;
    return [sCaptainTechSlotAdds[externalId] intValue];
}

NSDictionary* sCaptainCrewSlotAdds = nil;

-(int)additionalCrewSlots
{
    NSString* special = self.special;
    if ([special isEqualToString: @"Add_Crew_1"]) {
        return 1;
    }

    if (sCaptainCrewSlotAdds == nil) {
        sCaptainCrewSlotAdds = @{
            @"lore_71522": @1,
            @"calvin_hudson_71528": @1,
            @"chakotay_71528": @1,
            @"weyoun_71279": @2
        };
    }

    return [sCaptainCrewSlotAdds[self.externalId] intValue];
}

static NSDictionary* sCaptainWeaponSlotAdds = nil;

-(int)additionalWeaponSlots
{
    if (sCaptainWeaponSlotAdds == nil) {
        sCaptainWeaponSlotAdds = @{
            @"calvin_hudson_c_71528": @1,
            @"jean_luc_picard_c_71531": @1,
            @"chakotay_b_71528": @1
        };
    }

    if ([super additionalWeaponSlots]) {
        return [super additionalWeaponSlots];
    }
    return [sCaptainWeaponSlotAdds[self.externalId] intValue];
}

-(int)additionalTalentSlots
{
    return [self.talent intValue];
}

-(NSNumber*)eliteTalent
{
    return [self talent];
}

-(NSString*)sortStringForSet
{
    if ([self.externalId isEqualToString:@"gareb_71536"]) {
        return [NSString stringWithFormat: @"%@:b:%@:%c:%@", self.faction, self.upSortType, 0, self.title];
    }
    return [NSString stringWithFormat: @"%@:b:%@:%c:%@", self.faction, self.upSortType, 'z' - [self.skill intValue], self.title];
}

-(NSString*)itemDescription
{
    return [NSString stringWithFormat: @"%@ (%@)", self.title, self.skill];
}

@end
