#import "DockReferenceTabController.h"

@implementation DockReferenceTabController

#pragma mark - Filtering

-(BOOL)dependsOnFaction
{
    return NO;
}

#pragma mark Adding to ship

-(BOOL)canAddItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship
{
    return NO;
}

@end
