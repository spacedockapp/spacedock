//
//  DockSquad+Addons.m
//  Space Dock
//
//  Created by Rob Tsuk on 9/26/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import "DockSquad+Addons.h"
#import "DockEquippedShip+Addons.h"

@implementation DockSquad (Addons)

+ (NSSet *)keyPathsForValuesAffectingCost
{
    return [NSSet setWithObjects:@"equippedShips", nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self squadCompositionChanged];
}

-(void)watchForCostChange
{
    for (DockEquippedShip* es in self.equippedShips) {
        [es addObserver: self forKeyPath: @"cost" options: 0 context: 0];
    }
}

-(void)awakeFromInsert
{
    [super awakeFromInsert];
    [self watchForCostChange];
}

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    [self watchForCostChange];
}

-(void)addEquippedShip:(DockEquippedShip*)ship
{
    [self willChangeValueForKey: @"cost"];
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet: self.equippedShips];
    [tempSet addObject: ship];
    self.equippedShips = tempSet;
    [self didChangeValueForKey: @"cost"];
    [ship addObserver: self forKeyPath: @"cost" options: 0 context: 0];
}

-(void)removeEquippedShip:(DockEquippedShip*)ship
{
    [self willChangeValueForKey: @"cost"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:@"equippedShips"]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:ship];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"equippedShips"];
        [tmpOrderedSet removeObject:ship];
        [self setPrimitiveValue:tmpOrderedSet forKey:@"equippedShips"];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"equippedShips"];
    }
    [ship removeObserver:  self forKeyPath: @"cost"];
    [self didChangeValueForKey: @"cost"];
}

-(int)cost
{
    int cost = 0;
    for (DockEquippedShip* ship in self.equippedShips) {
        cost += [ship cost];
    }
    return cost;
}

-(void)squadCompositionChanged
{
    [self willChangeValueForKey: @"cost"];
    [self didChangeValueForKey: @"cost"];
}

@end
