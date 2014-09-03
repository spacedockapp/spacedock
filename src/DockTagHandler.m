#import "DockTagHandler.h"

#import "DockCaptainFactionTagHandler.h"
#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockIgnoreFactionRequirementHandler.h"
#import "DockPerShipLimitTagHandler.h"
#import "DockShip+Addons.h"
#import "DockShipClassContainsRestriction.h"
#import "DockShipClassContainsAdjustment.h"
#import "DockShipClassAdjustmentHandler.h"
#import "DockShipClassRequirementHandler.h"
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
    handlers[@"requires_raptor_class"] = [[DockShipClassRequirementHandler alloc] initWithShipClass: @"Raptor Class"];
    handlers[@"requires_romulan_science_vessel"] = [[DockShipClassRequirementHandler alloc] initWithShipClass: @"Romulan Science Vessel"];
    handlers[@"requires_suurok_class"] = [[DockShipClassRequirementHandler alloc] initWithShipClass: @"Suurok Class"];
    NSArray* shipClasses = @[  @"Jem'Hadar Battle Cruiser",  @"Jem'Hadar Battleship"];
    handlers[@"requires_battleship_or_cruiser"] = [[DockShipClassRequirementHandler alloc] initWithShipClasses: shipClasses];
    handlers[@"requires_jemhadar_ship"] = [[DockShipClassContainsRestriction alloc] initWithShipClassSubstrings: @[@"Jem'hadar"]
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
    
    // Cost adjusting handlers
    handlers[@"adjust_not_jemhadar_ship_plus_5"] = [[DockShipClassContainsAdjustment alloc] initWithShipClassSubstrings: @[@"Jem'hadar"]
                                                                                                             adjustment: 5 ];
    handlers[@"adjust_not_breen_ship_plus_5"] = [[DockShipClassContainsAdjustment alloc] initWithShipClassSubstrings: @[@"Breen"]
                                                                                                             adjustment: 5 ];
    handlers[@"adjust_not_breen_ship_plus_5"] = [[DockShipClassContainsAdjustment alloc] initWithShipClassSubstrings: @[@"Breen"]
                                                                                                             adjustment: 5 ];
    handlers[@"adjust_not_keldon_class_plus_5"] = [[DockShipClassAdjustmentHandler alloc] initWithShipClass: @"Cardassian Keldon Class"
                                                                                                             adjustment: 5 ];
    handlers[@"adjust_not_rsv_class_plus_5"] = [[DockShipClassAdjustmentHandler alloc] initWithShipClass: @"Romulan Science Vessel"
                                                                                                             adjustment: 5 ];

    sTagHandlers = [NSDictionary dictionaryWithDictionary: handlers];
}

+(id<DockRestrictionTag>)restrictionHandlerForTag:(NSString*)tag
{
    id v = [sTagHandlers objectForKey: tag];
    if ([[v class] conformsToProtocol: @protocol(DockRestrictionTag)]) {
        return v;
    }
    return nil;
}

+(id<DockRuleBendingTag>)ruleBendingHandlerForTag:(NSString*)tag
{
    id v = [sTagHandlers objectForKey: tag];
    if ([[v class] conformsToProtocol: @protocol(DockRuleBendingTag)]) {
        return v;
    }
    return nil;
}

+(id<DockCostAdjustingTag>)costAdjustingHandlerForTag:(NSString*)tag
{
    id v = [sTagHandlers objectForKey: tag];
    if ([[v class] conformsToProtocol: @protocol(DockCostAdjustingTag)]) {
        return v;
    }
    return nil;
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
    NSMutableArray* ruleBendingHandlers = [NSMutableArray arrayWithCapacity: 0];
    NSSet* tags = [NSSet setWithSet: upgrade.tags];
    for (DockTag* tag in tags) {
        id<DockRestrictionTag> handler = [DockTagHandler restrictionHandlerForTag: tag.value];
        if (handler) {
            if (handler.restriction) {
                [restrictions addObject: handler];
            } else {
                [ruleBendingHandlers addObject: handler];
            }
        }
    }
    
    NSSet* shipTags = [ship tags];
    for (DockTag* tag in shipTags) {
        id<DockRuleBendingTag> handler = [DockTagHandler ruleBendingHandlerForTag: tag.value];
        if (handler) {
            [ruleBendingHandlers addObject: handler];
        }
    }
    
    for (id<DockRestrictionTag> restriction in restrictions) {
        DockExplanation* explanation = [restriction canAdd: upgrade toShip: ship];
        BOOL ignore = NO;
        if (explanation != nil && !explanation.canAdd) {
            for (id<DockRuleBendingTag> other in ruleBendingHandlers) {
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

#pragma mark - Cost

+(int)costAdjustment:(DockUpgrade*)upgrade onShip:(DockEquippedShip*)ship
{
    int costAdjustment = 0;
    
    NSSet* tags = [NSSet setWithSet: upgrade.tags];
    for (DockTag* tag in tags) {
        id<DockCostAdjustingTag> handler = [DockTagHandler costAdjustingHandlerForTag: tag.value];
        if (handler) {
            costAdjustment += [handler costAdjustment: upgrade onShip: ship];
        }
    }
    
    return costAdjustment;
}

@end
