#import "DockResource+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"

@implementation DockResource (Addons)

static NSString* kSideboardExternalId = @"4003";
static NSString* kFlagshipExternalId = @"4004";
static NSString* kFedFighterSquadronExternalId = @"federation_attack_fighters_op6participation";
static NSString* kHidekiFighterSquadronExternalId = @"hideki_class_attack_squadron_op5participation";
static NSString* kFleetCaptainExternalId = @"fleet_captain_collectiveop2";
NSString* kOfficerCardsExternalId = @"officer_cards_collectiveop3";

+(DockResource*)resourceForId:(NSString*)externalId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Resource" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"externalId == %@", externalId];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

+(DockResource*)sideboardResource:(NSManagedObjectContext*)context
{
    return [DockResource resourceForId: kSideboardExternalId context: context];
}

+(DockResource*)flagshipResource:(NSManagedObjectContext*)context
{
    return [DockResource resourceForId: kFlagshipExternalId context: context];
}

-(NSString*)plainDescription
{
    return self.title;
}

-(NSString*)description
{
    return self.title;
}

-(BOOL)isSideboard
{
    return [self.externalId isEqualToString: kSideboardExternalId];
}

-(BOOL)isFlagship
{
    return [self.externalId isEqualToString: kFlagshipExternalId];
}

-(BOOL)isOfficerCards
{
    return [self.externalId isEqualToString: kOfficerCardsExternalId];
}

-(BOOL)isFleetCaptain
{
    return [self.externalId isEqualToString: kFleetCaptainExternalId];
}

-(BOOL)isEquippedIntoSquad:(DockSquad*)thisSquad
{
    if ([self isFleetCaptain]) {
        DockEquippedUpgrade* fc = [thisSquad equippedFleetCaptain];
        return fc != nil;
    }
    if ([self isFlagship]) {
        DockFlagship* flagship = [thisSquad flagship];
        return flagship != nil;
    }
    if ([self.externalId isEqualToString:@"front-line_retrofit_72941r"]) {
        return [thisSquad containsUniqueUpgradeWithName:self.title];
    }
    if ([self.externalId isEqualToString:@"captains_chair_72936r"]) {
        return [thisSquad containsUniqueUpgradeWithName:self.title];
    }
    return [self isSideboard] || [self isFighterSquadron] || [self isOfficerCards];
}

-(BOOL)isEquippedIntoSquad
{
    return [self isEquippedIntoSquad: nil];
}

-(BOOL)isFighterSquadron
{
    NSString* externalId = self.externalId;
    return [externalId isEqualToString: kFedFighterSquadronExternalId] || [externalId isEqualToString: kHidekiFighterSquadronExternalId];
}

-(DockShip*)associatedShip
{
    if ([self isFighterSquadron]) {
        NSString* externalId = self.externalId;
        if ([externalId isEqualToString: kFedFighterSquadronExternalId]) {
            DockShip* ship = [DockShip shipForId: @"federation_attack_fighter_op6prize" context: self.managedObjectContext];
            return ship;
        }
        if ([externalId isEqualToString: kHidekiFighterSquadronExternalId]) {
            DockShip* ship = [DockShip shipForId: @"hideki_class_attack_fighter_op5prize" context: self.managedObjectContext];
            return ship;
        }
    }
    NSLog(@"No associated ship for %@", self);
    return nil;
}

-(NSString*)itemDescription
{
    return [self plainDescription];
}

-(NSString*)asPlainTextFormat
{
    return [NSString stringWithFormat: @"%@ (%@)\n", self.title, [self cost]];
}

-(NSNumber*)costForSquad:(DockSquad*)squad
{
    if ([self.externalId isEqualToString:@"emergency_force_fields_72001r"]) {
        int shields = 0;
        for (DockEquippedShip* ship in squad.equippedShips) {
            shields += ship.shield;
        }
        float cost = (float)shields/2.0f;

        return [NSNumber numberWithInt:ceil(cost)];
    } else if ([self.externalId isEqualToString:@"main_power_grid_72005r"]) {
            int hull = 0;
            for (DockEquippedShip* ship in squad.equippedShips) {
                if (ship.hull > 3) {
                    hull ++;
                }
            }
            float cost = 3.0f + ((float)hull*2.0f);
            
            return [NSNumber numberWithInt:ceil(cost)];
    } else if ([self.externalId isEqualToString:@"improved_hull_72319r"]) {
        int hull = 0;
        for (DockEquippedShip* ship in squad.equippedShips) {
            hull += ship.hull;
        }
        float cost = (float)hull/2.0f;
        
        return [NSNumber numberWithInt:ceil(cost)];
    } else if ([self.externalId isEqualToString:@"captains_chair_72936r"]) {
        if ([squad containsUniqueUpgradeWithName:@"Captain's Chair"] != nil) {
            return 0;
        } else {
            return self.cost;
        }
    } else if ([self.externalId isEqualToString:@"front-line_retrofit_72941r"]) {
        if ([squad containsUniqueUpgradeWithName:@"Front-Line Retrofit"] != nil) {
            return 0;
        } else {
            return self.cost;
        }
    } else {
        return self.cost;
    }
}

@end
