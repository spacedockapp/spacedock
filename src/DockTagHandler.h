#import <Foundation/Foundation.h>

@class DockExplanation;
@class DockEquippedShip;
@class DockUpgrade;

@interface DockTagHandler : NSObject
+(void)registerTagHandlers:(NSArray*)allFactionNames;
+(DockTagHandler*)handlerForTag:(NSString*)tag;
+(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)ship;
-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)ship;
-(NSString*)standardFailureResult:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip;
-(NSString*)standardFailureExplanation:(NSString*)reason;
-(BOOL)refersToShipOrShipClass;
-(BOOL)ignoresFactionRestrictions:(DockUpgrade*)upgrade;
-(BOOL)restriction;
-(BOOL)restrictsByFaction;
@end
