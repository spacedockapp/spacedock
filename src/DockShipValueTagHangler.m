#import "DockShipValueTagHangler.h"

#import "DockEquippedShip+Addons.h"
#import "DockExplanation.h"
#import "DockShip+Addons.h"

@interface DockShipValueTagHangler ()
@property (strong,nonatomic) NSString* valueName;
@property (assign, nonatomic) NSRange legalRange;
@end

@implementation DockShipValueTagHangler

-(id)initWithValue:(NSString*)valueName range:(NSRange)legalRange
{
    self = [super init];
    if (self != nil) {
        self.valueName = valueName;
        self.legalRange = legalRange;
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
    
    NSInteger value = [[ship valueForKey: _valueName] integerValue];
    
    if (NSLocationInRange(value, _legalRange)) {
        return [DockExplanation success];
    }
    
    NSString* result = [self standardFailureResult: upgrade toShip: equippedShip];
    NSString* explanationFragment = [NSString stringWithFormat: @"a ship with a %@ value between %ld and %ld", _valueName,
        _legalRange.location, NSMaxRange(_legalRange)-1];
    NSString* explanation = [self standardFailureExplanation: explanationFragment];
    
    return [[DockExplanation alloc] initWithResult: result explanation: explanation];
}
@end
