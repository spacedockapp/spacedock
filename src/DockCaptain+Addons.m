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
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"cost = 0 and faction like %@", faction];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
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
            if ([captainSets intersectsSet: targetShipSets]) {
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

-(int)additionalTechSlots
{
    NSString* special = self.special;
    if ([special isEqualToString: @"addonetechslot"] || [special isEqualToString: @"AddsHiddenTechSlot"]) {
        return 1;
    }
    return 0;
}

-(int)additionalCrewSlots
{
    if ([self.externalId isEqualToString: @"lore_71522"]) {
        return 1;
    }

    NSString* special = self.special;
    if ([special isEqualToString: @"Add_Crew_1"]) {
        return 1;
    }
    return [special isEqualToString: @"AddTwoCrewSlotsDominionCostBonus"] ? 2 : 0;
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
    return [NSString stringWithFormat: @"%@:b:%@:%c:%@", self.faction, self.upSortType, 'z' - [self.skill intValue], self.title];
}

-(NSString*)itemDescription
{
    return [NSString stringWithFormat: @"%@ (%@)", self.title, self.skill];
}

@end
