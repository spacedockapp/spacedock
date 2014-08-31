#import "DockResource+Addons.h"
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

@end
