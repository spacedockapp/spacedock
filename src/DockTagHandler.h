#import <Foundation/Foundation.h>

@class DockExplanation;
@class DockEquippedShip;
@class DockUpgrade;

@protocol DockRestrictionTag;
@protocol DockRuleBendingTag;
@protocol DockCostAdjustingTag;

@interface DockTagHandler : NSObject
+(void)registerTagHandlers:(NSArray*)allFactionNames;
+(id<DockRestrictionTag>)restrictionHandlerForTag:(NSString*)tag;
+(id<DockRuleBendingTag>)ruleBendingHandlerForTag:(NSString*)tag;
+(id<DockCostAdjustingTag>)costAdjustingHandlerForTag:(NSString*)tag;
+(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)ship;
+(int)costAdjustment:(DockUpgrade*)upgrade onShip:(DockEquippedShip*)ship;
-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)ship;
-(NSString*)standardFailureResult:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)equippedShip;
-(NSString*)standardFailureExplanation:(NSString*)reason;
-(BOOL)refersToShipOrShipClass;
-(BOOL)ignoresFactionRestrictions:(DockUpgrade*)upgrade;
-(BOOL)restriction;
-(BOOL)restrictsByFaction;
@end

@protocol DockRestrictionTag <NSObject>
-(DockExplanation*)canAdd:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)ship;
-(BOOL)restrictsByFaction;
-(BOOL)restriction;
@end

@protocol DockRuleBendingTag <NSObject>
-(BOOL)ignoresFactionRestrictions:(DockUpgrade*)upgrade;
-(BOOL)ignoresFactionPenalty:(DockUpgrade*)upgrade;
@end

@protocol DockCostAdjustingTag <NSObject>
-(int)costAdjustment:(DockUpgrade*)upgrade onShip:(DockEquippedShip*)ship;
@end

