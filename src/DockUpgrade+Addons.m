#import "DockUpgrade+Addons.h"

#import "DockWeapon.h"
#import "DockTech.h"
#import "DockTalent.h"
#import "DockCrew.h"
#import "DockCaptain+Addons.h"
#import "DockResource.h"
#import "DockShip+Addons.h"
#import "DockEquippedShip+Addons.h"

@implementation DockUpgrade (Addons)

+(DockUpgrade*)placeholder:(NSString*)upType inContext:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: upType inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"placeholder = YES"];
    [request setPredicate: predicateTemplate];
    DockUpgrade* placeholderUpgrade = nil;
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];
    NSLog(@"placeholders = %@", existingItems);
    if (existingItems.count == 0) {
        Class upClass = [DockUpgrade class];
        if ([upType isEqualToString: @"Weapon"]) {
            upClass = [DockWeapon class];
        } else if ([upType isEqualToString: @"Tech"]) {
            upClass = [DockTech class];
        } else if ([upType isEqualToString: @"Talent"]) {
            upClass = [DockTalent class];
        } else if ([upType isEqualToString: @"Captain"]) {
            upClass = [DockCaptain class];
        } else if ([upType isEqualToString: @"Crew"]) {
            upClass = [DockCrew class];
        }
        placeholderUpgrade = [[upClass alloc] initWithEntity: entity insertIntoManagedObjectContext: context];
        placeholderUpgrade.title = upType;
        placeholderUpgrade.upType = upType;
        placeholderUpgrade.placeholder = @YES;
    } else {
        placeholderUpgrade = existingItems[0];
    }
    return placeholderUpgrade;
}

-(NSString*)description
{
    if ([self isPlaceholder]) {
        return self.title;
    }
    return [NSString stringWithFormat: @"%@ (%@)", self.title, self.upType];
}

-(BOOL)isTalent
{
    return [self.upType isEqualToString: @"Talent"];
}

-(BOOL)isCrew
{
    return [self.upType isEqualToString: @"Crew"];
}

-(BOOL)isWeapon
{
    return [self.upType isEqualToString: @"Weapon"];
}

-(BOOL)isCaptain
{
    return [self.upType isEqualToString: @"Captain"];
}

-(BOOL)isTech
{
    return [self.upType isEqualToString: @"Tech"];
}

-(BOOL)isPlaceholder
{
    return [[self placeholder] boolValue];
}

-(NSComparisonResult)compareTo:(DockUpgrade*)other
{
    NSString* upTypeMe = self.upType;
    NSString* upTypeOther = other.upType;
    NSComparisonResult r = [upTypeMe compare:upTypeOther];
    if (r == NSOrderedSame) {
        return [self.title caseInsensitiveCompare: other.title];
    }

    if ([upTypeMe isEqualToString: @"Captain"]) {
        return NSOrderedAscending;
    }

    if ([upTypeOther isEqualToString: @"Captain"]) {
        return NSOrderedDescending;
    }

    return r;
}

-(int)limitForShip:(DockEquippedShip*)targetShip
{
    if ([self isTalent]) {
        DockCaptain* captain = [targetShip captain];
        return [captain talentCount];
    }
    
    DockShip* ship = targetShip.ship;
    
    if ([self isWeapon]) {
        return [ship weaponCount];
    }
    
    if ([self isCrew]) {
        return [ship crewCount];
    }
    
    if ([self isTech]) {
        return [ship techCount];
    }
    
    return 0;
}

@end
