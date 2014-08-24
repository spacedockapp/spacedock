#import "DockReferenceTabController.h"

@implementation DockReferenceTabController

# pragma mark - Table selection

-(NSString*)notificationName
{
    return kCurrentReferenceChanged;
}

#pragma mark - Filtering

-(BOOL)dependsOnFaction
{
    return NO;
}

#pragma mark Adding to ship

-(BOOL)canAddItem:(DockComponent*)item toShip:(DockEquippedShip*)ship
{
    return NO;
}

@end
