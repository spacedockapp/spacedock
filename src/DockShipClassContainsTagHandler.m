#import "DockShipClassContainsTagHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockShipClassContainsTagHandler ()
@property (strong,nonatomic) NSSet* shipClassSubstrings;
@property (strong,nonatomic) NSString* explanationFragment;
@end

@implementation DockShipClassContainsTagHandler

-(id)initWithShipClassSubstrings:(NSArray*)shipClassSubstrings explanationFragment:(NSString*)explanationFragment
{
    self = [super init];
    if (self != nil) {
        self.shipClassSubstrings = [NSSet setWithArray: shipClassSubstrings];
        self.explanationFragment = explanationFragment;
    }
    return self;
}

#pragma mark - Tag attributes

-(BOOL)restriction
{
    return YES;
}

#pragma mark - Restriction

-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip
{
    DockShip* ship = equippedShip.ship;
    NSString* shipClass = ship.shipClass;
    
    for (NSString* substring in _shipClassSubstrings) {
        NSRange r = [shipClass rangeOfString: substring options: NSCaseInsensitiveSearch];
        if (r.location != NSNotFound) {
            return [DockExplanation success];
        }
    }
    
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* explanation = [self standardFailureExplanation: _explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}
@end
