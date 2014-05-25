#import "DockShip+Viper.h"

#import "DockShip+MacAddons.h"
#import "DockUtilsMac.h"
#import "DockWeaponRange.h"

@implementation DockShip (Viper)

-(DockWeaponRange*)shipWeaponRange
{
    return [[DockWeaponRange alloc] initWithString: self.shipRange];
}

-(DockWeaponRange*)craftWeaponRange
{
    return [[DockWeaponRange alloc] initWithString: self.craftRange];
}

-(NSString*)plainDescription
{
    return self.title;
}

-(NSString*)descriptiveTitle
{
    return self.title;
}

-(NSString*)classStrength
{
    if (self.wingStrength.length > 0) {
        return [NSString stringWithFormat: @"%@ - %@", self.shipClass, self.wingStrength];
    }
    return self.shipClass;
}

-(DockShip*)stepReduction:(int)step
{
    NSManagedObjectContext* context = [self managedObjectContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Ship" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"(shipClass like[cd] %@) AND (title like[cd] %@) AND (step == %@)", self.shipClass, self.title, [NSNumber numberWithInt: step]];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

@end
