#import "DockSetTabController.h"

#import "DockAppDelegate.h"
#import "DockSet+Addons.h"
#import "DockSetItem+Addons.h"

@implementation DockSetTabController

#pragma mark - Filtering

-(BOOL)managesSetItems
{
    return NO;
}

-(BOOL)dependsOnFaction
{
    return NO;
}

#pragma mark - sorting

-(NSArray*)createSortDescriptors
{
    return @[
        [[NSSortDescriptor alloc] initWithKey: @"releaseDate" ascending: YES],
        [[NSSortDescriptor alloc] initWithKey: @"productName" ascending: YES],
    ];
}

#pragma mark - Filtering

-(void)addAdditionalPredicatesForSearchTerm:(NSString*)searchTerm formatParts:(NSMutableArray*)formatParts arguments:(NSMutableArray*)arguments
{
    [formatParts addObject: @"(productName contains[cd] %@)"];
    [arguments addObject: searchTerm];
}


#pragma mark - Adding to ship

-(BOOL)canAddItem:(DockSetItem*)item toShip:(DockEquippedShip*)ship
{
    return NO;
}

-(NSString*)copySelectedSet
{
    NSMutableArray* lines = [NSMutableArray arrayWithCapacity: 0];
    NSArray* selectedItems = [self.targetController selectedObjects];
    for (DockSet* set in selectedItems) {
        [lines addObject: [NSString stringWithFormat: @"%@ (%@)", set.productName, set.externalId]];
        [lines addObject: @""];
        NSArray* items = [set sortedSetItems];
        for (id item in items) {
            [lines addObject: [item itemDescription]];
        }
        [lines addObject: @""];
        [lines addObject: @""];
    }
    
    return [lines componentsJoinedByString: @"\n"];
}

#pragma mark - Actions

-(IBAction)includeSelectedSets:(id)sender
{
    NSArray* selectedItems = [self.targetController selectedObjects];
    for (DockSet* set in selectedItems) {
        set.include = @YES;
    }
}

-(IBAction)includeOnlySelectedSets:(id)sender
{
    NSArray* selectedItems = [self.targetController selectedObjects];
    for (DockSet* set in [DockSet allSets: self.appDelegate.managedObjectContext]) {
        set.include = @([selectedItems containsObject: set]);
    }
}

-(IBAction)excludeSelectedSets:(id)sender
{
    NSArray* selectedItems = [self.targetController selectedObjects];
    for (DockSet* set in selectedItems) {
        set.include = @NO;
    }
}

@end
