#import "DockSet+Addons.h"

#import "DockComponent+Addons.h"

@implementation DockSet (Addons)

+(DockSet*)setForId:(NSString*)setId context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Set" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"externalId == %@", setId];
    [request setPredicate: predicateTemplate];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];

    if (existingItems.count > 0) {
        return existingItems[0];
    }

    return nil;
}

+(NSArray*)allSets:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Set" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    return [context executeFetchRequest: request error: &err];
}

+(NSArray*)includedSets:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Set" inManagedObjectContext: context];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat: @"include == true"];
    [request setPredicate: predicateTemplate];
    NSError* err;
    return [context executeFetchRequest: request error: &err];
}

-(NSArray*)sortedSetItems
{
    NSArray* unsortedItems = [self.items allObjects];
    id compareSetItem = ^(DockComponent* a, DockComponent* b) {
        return [a compareForSet: b];
    };
    return [unsortedItems sortedArrayUsingComparator: compareSetItem];
}

-(NSString*)setCode
{
    NSDictionary* setCodes =
  @{
    @"Khan Singh GenCon 2013 Promo" : @"GenKhan",
    @"Dominion War OP1 Participation Prize" : @"DomWarPP1",
    @"Dominion War OP1 Competitive Prize" : @"Krayton",
    @"Dominion War OP2 Participation Prize" : @"DomWarPP2",
    @"Dominion War OP2 Competitive Prize" : @"Ch'Tang",
    @"Dominion War OP3 Participation Prize" : @"DomWarPP3",
    @"Dominion War OP3 Competitive Prize" : @"Aj'rmr",
    @"Dominion War OP4 Participation Prize" : @"DomWarPP4",
    @"Dominion War OP4 Competitive Prize" : @"Sutherland",
    @"Dominion War OP5 Participation Prize" : @"DomWarPP5",
    @"Dominion War OP5 Competitive Prize" : @"Laerst",
    @"Dominion War OP6 Participation Prize" : @"DomWarPP6",
    @"Dominion War OP6 Competitive Prize" : @"Akorem",
    @"Tholian Web Participation Prize" : @"TWebPP",
    @"Tholian Web Competitive Prize" : @"Tholia",
    @"Arena Participation Prize" : @"ArenaPP",
    @"Arena Competitive Prize" : @"S'Gorn",
    @"The Collective OP1 Participation Prize" : @"CollectivePP1",
    @"The Collective OP2 Participation Prize" : @"CollectivePP2",
    @"Ti'Mur Competitive Prize" : @"Ti’Mur",
    @"I.K.S. B'Moth Expansion" : @"B’Moth",
    @"Gavroche Expansion" : @"Gavroch",
    @"I.R.W. Vorta Vor Expansion" : @"Vorta Vor",
    @"3rd Wing Attack Ship Expansion" : @"3rd Wing",
    @"U.S.S. Yeager Expansion" : @"Yeager",
    @"Starter Set" : @"Starter",
    @"U.S.S. Reliant Expansion" : @"Reliant",
    @"U.S.S. Enterprise Expansion" : @"Enterprise",
    @"I.R.W. Valdore Expansion" : @"Valdore",
    @"R.I.S. Apnex Expansion" : @"Apnex",
    @"I.K.S. Gr''oth Expansion" : @"Gr''oth",
    @"I.K.S. Negh''var Expansion" : @"Negh''var",
    @"Kraxon Expansion" : @"Kraxon",
    @"Gor Portas Expansion" : @"Portas",
    @"U.S.S. Defiant Expansion" : @"Defiant",
    @"I.K.S. Kronos One Expansion" : @"Kronos",
    @"I.R.W. Praetus Expansion" : @"Praetus",
    @"5th Wing Patrol Ship Expansion" : @"5th Wing",
    @"U.S.S. Excelsior Expansion" : @"Excelsior",
    @"I.K.S. Koraga Expansion" : @"Koraga",
    @"R.I.S. Vo Expansion" : @"Vo",
    @"Koranak Expansion" : @"Koranak",
    @"U.S.S. Equinox Expansion" : @"Equinox",
    @"I.K.S. Somraw Expansion" : @"Somraw",
    @"R.I.S. Gal Gath'thong Expansion" : @"Gal",
    @"4th Division Battleship Expansion" : @"Battleship",
    @"U.S.S. Voyager Expansion" : @"Voyager",
    @"Bioship Alpha Expansion" : @"Bioship",
    @"Nistrim Raider Expansion" : @"Nistrim",
    @"Borg Sphere 4270 Expansion" : @"Sphere",
    @"Tactical Cube Expansion" : @"Cube",
    @"Interceptor Five Expansion" : @"Interceptor",
    @"D’Kyr Expansion" : @"D’Kyr",
    @"U.S.S. Enterprise (Refit) Expansion" : @"Refit",
    @"Soong Expansion" : @"Soong",
    @"Battle Cruiser Expansion" : @"Cruiser",
    @"U.S.S. Raven Competitive Prize" : @"Raven",
    };

    NSString* setCode = setCodes[self.productName];
    if (setCode == nil) {
        setCode = self.productName;
    }
    return setCode;
}

@end
