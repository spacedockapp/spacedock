#import "DockShipClassDetails+Addons.h"

#import "DockManeuver.h"

@implementation DockShipClassDetails (Addons)

+(DockShipClassDetails*)find:(NSString*)shipClass context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"ShipClassDetails" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"name CONTAINS %@", shipClass];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

-(void)removeAllManeuvers
{
    [self setManeuvers: [NSSet set]];
}

-(void)addManeuver:(DockManeuver*)maneuver
{
    [self addManeuvers: [NSSet setWithObject: maneuver]];
}

-(void)updateManeuvers:(NSArray*)m
{
    NSMutableArray* mData = [NSMutableArray arrayWithCapacity: 0];
    for (DockManeuver* move in self.maneuvers) {
        NSDictionary* moveData = @{
            @"speed":  move.speed,
            @"color":  move.color,
            @"kind":  move.kind
        };
        [mData addObject: moveData];
    }
    
    id compareData = ^(NSDictionary* a, NSDictionary* b) {
        NSArray* keys = @[@"speed", @"kind", @"color"];
        NSComparisonResult r;
        for (NSString* key in keys) {
            id aValue = a[key];
            id bValue = b[key];
            r = [aValue compare: bValue];
            if (r != NSOrderedSame) {
                break;
            }
        }
        return r;
    };
    m = [m sortedArrayUsingComparator: compareData];
    [mData sortUsingComparator: compareData];
    NSString* s1 = [m componentsJoinedByString: @","];
    NSString* s2 = [mData componentsJoinedByString: @","];
    if ([s1 isEqualToString: s2]) {
        return;
    }
    NSManagedObjectContext* context = self.managedObjectContext;
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Maneuver" inManagedObjectContext: context];

    NSMutableSet* mSet = [NSMutableSet setWithCapacity: 0];
    for (NSDictionary* oneMove in m) {
        DockManeuver* maneuver = [[DockManeuver alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
        NSString* speedString = oneMove[@"speed"];
        int speedInt = [speedString intValue];
        maneuver.speed = [NSNumber numberWithInt: speedInt];
        maneuver.kind = oneMove[@"kind"];
        maneuver.color = oneMove[@"color"];
        [mSet addObject: maneuver];
    }
    self.maneuvers = mSet;
}

@end
