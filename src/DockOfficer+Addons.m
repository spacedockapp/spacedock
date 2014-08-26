#import "DockOfficer+Addons.h"

#import "DockResource+Addons.h"

@implementation DockOfficer (Addons)

-(DockResource*)associatedResource
{
    return [DockResource resourceForId: @"officer_cards_collectiveop3" context: self.managedObjectContext];
}

@end
