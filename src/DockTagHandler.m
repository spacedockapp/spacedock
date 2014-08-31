#import "DockTagHandler.h"

#import "DockCaptainFactionTagHandler.h"
#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockIgnoreFactionRequirementHandler.h"
#import "DockPerShipLimitTagHandler.h"
#import "DockShip+Addons.h"
#import "DockShipClassContainsTagHandler.h"
#import "DockShipClassTagHandler.h"
#import "DockShipFactionTagHandler.h"
#import "DockShipValueTagHangler.h"
#import "DockTag+Addons.h"
#import "DockTitledShipTagHandler.h"
#import "DockUpgrade+Addons.h"

static NSDictionary* sTagHandlers = nil;

@implementation DockTagHandler

+(void)registerTagHandlers:(NSArray*)allFactionNames
{
    NSMutableDictionary* handlers = [[NSMutableDictionary alloc] initWithCapacity: 0];
    
    // ship class restrictions
    handlers[@"requires_raptor_class"] = [[DockShipClassTagHandler alloc] initWithShipClass: @"Raptor Class"];
    handlers[@"requires_romulan_science_vessel"] = [[DockShipClassTagHandler alloc] initWithShipClass: @"Romulan Science Vessel"];
    handlers[@"requires_suurok_class"] = [[DockShipClassTagHandler alloc] initWithShipClass: @"Suurok Class"];
    NSArray* shipClasses = @[  @"Jem'Hadar Battle Cruiser",  @"Jem'Hadar Battleship"];
    handlers[@"requires_battleship_or_cruiser"] = [[DockShipClassTagHandler alloc] initWithShipClasses: shipClasses];
    handlers[@"requires_jemhadar_ship"] = [[DockShipClassContainsTagHandler alloc] initWithShipClassSubstrings: @[@"Jem'hadar"]
        explanationFragment: @"Jem'hadar ships"];
    
    // named ship restrictions
    handlers[@"requires_voyager"] = [[DockTitledShipTagHandler alloc] initWithShipTitle: @"U.S.S. Voyager"];

    // Captain and Ship faction restrictions
    for (NSString* faction in allFactionNames) {
        NSString* convertedFaction = [[faction lowercaseString] stringByReplacingOccurrencesOfString: @" " withString: @""];
        NSString* shipFactionTag = [NSString stringWithFormat: @"requires_%@_ship", convertedFaction];
        handlers[shipFactionTag] = [[DockShipFactionTagHandler alloc] initWithFaction: faction];
        NSString* captainFactionTag = [NSString stringWithFormat: @"requires_%@_captain", convertedFaction];
        handlers[captainFactionTag] = [[DockCaptainFactionTagHandler alloc] initWithFaction: faction];
    }
    
    // Misc restrictions
    NSSet* talentsSet = [NSSet setWithArray: @[@"Talent"]];
    handlers[@"require_hull_3_or_less"] = [[DockShipValueTagHangler alloc] initWithValue: @"hull" range: NSMakeRange(1, 3)];
    handlers[@"require_no_more_than_one_per_ship"] = [[DockPerShipLimitTagHandler alloc] initWithLimit: 1];

    // Rule bending handlers
    handlers[@"ignores_faction_requirement_for_talents"] = [[DockIgnoreFactionRequirementHandler alloc] initWithTypes: talentsSet];

    sTagHandlers = [NSDictionary dictionaryWithDictionary: handlers];
}

+(DockTagHandler*)handlerForTag:(NSString*)tag
{
    return [sTagHandlers objectForKey: tag];
}

#pragma mark - Tag attributes

-(BOOL)refersToShipOrShipClass
{
    return NO;
}

-(BOOL)ignoresFactionRestrictions:(DockUpgrade*)upgrade
{
    return NO;
}

-(BOOL)restrictsByFaction
{
    return NO;
}

-(BOOL)restriction
{
    return self.restrictsByFaction;
}

#pragma mark - Restriction

+(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)ship
{
    NSMutableArray* restrictions = [NSMutableArray arrayWithCapacity: 0];
    NSMutableArray* otherHandlers = [NSMutableArray arrayWithCapacity: 0];
    NSSet* tags = [NSSet setWithSet: upgrade.tags];
    for (DockTag* tag in tags) {
        DockTagHandler* handler = [DockTagHandler handlerForTag: tag.value];
        if (handler) {
            if (handler.restriction) {
                [restrictions addObject: handler];
            } else {
                [otherHandlers addObject: handler];
            }
        }
    }
    
    NSSet* shipTags = [ship tags];
    for (DockTag* tag in shipTags) {
        DockTagHandler* handler = [DockTagHandler handlerForTag: tag.value];
        if (handler) {
            [otherHandlers addObject: handler];
        }
    }
    
    for (DockTagHandler* restriction in restrictions) {
        DockExplanation* explanation = [restriction canAdd: upgrade toShip: ship];
        BOOL ignore = NO;
        if (explanation != nil && !explanation.canAdd) {
            for (DockTagHandler* other in otherHandlers) {
                if ([other ignoresFactionRestrictions: upgrade]) {
                    ignore = YES;
                    break;
                }
            }
        }
        if (!ignore) {
            return explanation;
        }
    }
    return nil;
}

-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)ship
{
    return [DockExplanation success];
}

#pragma mark - Explanation

-(NSString*)standardFailureResult:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip
{
    return [NSString stringWithFormat: @"Can't add %@ to %@", [upgrade plainDescription], [equippedShip.ship plainDescription]];
}

-(NSString*)standardFailureExplanation:(NSString*)reason
{
    return [NSString stringWithFormat: @"This Upgrade can only be purchased for %@.", reason];
}

@end
