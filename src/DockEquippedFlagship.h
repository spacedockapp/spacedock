#import <Foundation/Foundation.h>

@class DockFlagship;
@class DockEquippedShip;

@interface DockEquippedFlagship : NSObject
@property (strong, nonatomic) DockFlagship* flagship;
@property (strong, nonatomic) DockEquippedShip* equippedShip;
+(DockEquippedFlagship*)equippedFlagship:(DockFlagship*)flagship forShip:(DockEquippedShip*)ship;
@end
