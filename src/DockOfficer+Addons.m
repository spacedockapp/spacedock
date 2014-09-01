#import "DockOfficer+Addons.h"

#import "DockResource+Addons.h"

@implementation DockOfficer (Addons)

-(DockResource*)associatedResource
{
    return [DockResource resourceForId: kOfficerCardsExternalId context: self.managedObjectContext];
}

-(NSString*)factionCode
{
    return @"";
}

@end
