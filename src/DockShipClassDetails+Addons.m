#import "DockShipClassDetails+Addons.h"

#import "DockManeuver+Addons.h"

@implementation DockShipClassDetails (Addons)

+(DockShipClassDetails*)find:(NSString*)shipClass context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"ShipClassDetails" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"name == %@", shipClass];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

+(DockShipClassDetails*)shipClassDetailsForId:(NSString*)shipClassId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"ShipClassDetails" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"externalId == %@", shipClassId];
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
        NSComparisonResult r = NSOrderedSame;

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

-(BOOL)hasRearFiringArc
{
    return [self.rearArc length] > 0;
}

-(DockManeuver*)getDockManeuver:(int)speed kind:(NSString*)kind
{
    for (DockManeuver* m in self.maneuvers) {
        if ([m.speed intValue] == speed && [m.kind isEqualToString: kind]) {
            return m;
        }
    }
    return nil;
}

-(NSString*)movesSummary
{
    NSMutableSet* specials = [NSMutableSet setWithCapacity: 0];

    for (DockManeuver* m in self.maneuvers) {
        if ([m.kind hasSuffix: @"spin"]) {
            [specials addObject: @"spin"];
        } else if ([m.kind isEqualToString: @"about"]) {
            [specials addObject: @"come about"];
        } else if ([m.speed intValue] < 0 && [m.kind isEqualToString: @"straight"]) {
            [specials addObject: @"backup"];
        } else if ([m.kind isEqualToString: @"stop"]) {
            [specials addObject: @"all stop"];
        } else if ([m.kind hasSuffix: @"rotate"]) {
            [specials addObject: @"rotate"];
        } else if ([m.speed intValue] >= 5 && ![m.color isEqualToString:@"red"]) {
            [specials addObject: @"fast"];
        }

    }
    return [[specials allObjects] componentsJoinedByString: @","];
}

-(NSSet*)speeds
{
    NSMutableSet* speeds = [NSMutableSet setWithCapacity: 0];

    for (DockManeuver* m in self.maneuvers) {
        [speeds addObject: m.speed];
    }
    return [NSSet setWithSet: speeds];
}

-(BOOL)hasSpins
{
    id finder = ^(id obj, NSUInteger idx, BOOL *stop) {
        DockManeuver* m = obj;
        return m.isSpin;
    };
    NSInteger index =  [self.maneuvers.allObjects indexOfObjectPassingTest: finder];
    return index != NSNotFound;
}

-(BOOL)hasFlanks
{
    id finder = ^(id obj, NSUInteger idx, BOOL *stop) {
        DockManeuver* m = obj;
        return m.isFlank;
    };
    NSInteger index =  [self.maneuvers.allObjects indexOfObjectPassingTest: finder];
    return index != NSNotFound;
}

-(BOOL)hasComeAbout
{
    id finder = ^(id obj, NSUInteger idx, BOOL *stop) {
        DockManeuver* m = obj;
        return m.isComeAbout;
    };
    NSInteger index =  [self.maneuvers.allObjects indexOfObjectPassingTest: finder];
    return index != NSNotFound;
}
@end
