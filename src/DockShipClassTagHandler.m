#import "DockShipClassTagHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockShipClassTagHandler ()
@property (strong,nonatomic) NSSet* targetShipClassSet;
@end

@implementation DockShipClassTagHandler

-(id)initWithShipClassSet:(NSSet*)shipClassSet
{
    self = [super init];
    if (self != nil) {
        self.targetShipClassSet = shipClassSet;
    }
    return self;
}

-(id)initWithShipClass:(NSString*)shipClass
{
    return [self initWithShipClassSet: [NSSet setWithObject: shipClass]];
}

-(id)initWithShipClasses:(NSArray*)shipClasses
{
    return [self initWithShipClassSet: [NSSet setWithArray: shipClasses]];
}

#pragma mark - Tag attributes

-(BOOL)refersToShipOrShipClass
{
    return YES;
}

-(BOOL)restriction
{
    return YES;
}

#pragma mark - Restriction

-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip
{
    DockShip* ship = equippedShip.ship;
    
    if ([_targetShipClassSet containsObject: ship.shipClass]) {
        return [DockExplanation success];
    }
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* shipClassString = @"";
    if (_targetShipClassSet.count > 2) {
        NSMutableArray* shipClasses = [NSMutableArray arrayWithArray: [_targetShipClassSet allObjects]];
        NSArray* allButLast = [shipClasses subarrayWithRange: NSMakeRange(0, shipClasses.count - 1)];
        NSString* firstClassesString = [allButLast componentsJoinedByString: @", "];
        shipClassString = [@[firstClassesString, shipClasses.lastObject] componentsJoinedByString: @" or "];
    } else if (_targetShipClassSet.count == 2) {
        shipClassString = [[_targetShipClassSet allObjects] componentsJoinedByString: @" or "];
    } else {
        shipClassString = _targetShipClassSet.anyObject;
    }
    NSString* explanationFragment = [NSString stringWithFormat: @"ships of class %@", shipClassString];
    NSString* explanation = [self standardFailureExplanation: explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}

@end
