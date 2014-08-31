#import "DockTitledShipTagHandler.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockTitledShipTagHandler ()
@property (strong,nonatomic) NSString* shipTitle;
@end

@implementation DockTitledShipTagHandler


-(id)initWithShipTitle:(NSString*)shipTitle
{
    self = [super init];
    if (self != nil) {
        self.shipTitle = shipTitle;
    }
    return self;
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
    
    if ([ship.title isEqualToString: self.shipTitle]) {
        return [DockExplanation success];
    }
    
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* explanationFragment = [NSString stringWithFormat: @"a ship titled %@", self.shipTitle];
    NSString* explanation = [self standardFailureExplanation: explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}

@end
