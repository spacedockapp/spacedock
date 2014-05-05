#import "DockViperDataLoader.h"

#import "DockCaptain.h"
#import "DockCrew+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"
#import "DockSet+Addons.h"
#import "DockTalent.h"
#import "DockTech.h"
#import "DockUtils.h"
#import "DockWeapon.h"

@interface DockViperDataLoader ()
@property (readonly, weak, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSString* pathToDataFiles;
@end

@implementation DockViperDataLoader

-(id)initWithContext:(NSManagedObjectContext*)context pathToDataFiles:(NSString*)pathToDataFiles
{
    self = [super init];
    if (self != nil) {
        _managedObjectContext = context;
        _pathToDataFiles = pathToDataFiles;
    }
    return self;
}

static NSString* makeKey(NSString* key)
{
    if (key.length < 1) {
        return @"";
    } else if ([key isEqualToString: @"Name"]) {
        return @"title";
    } else if ([key isEqualToString: @"ID"]) {
        return @"externalId";
    } else if ([key isEqualToString: @"Evade"]) {
        return @"evasiveManeuvers";
    } else if ([key isEqualToString: @"Class"]) {
        return @"shipClass";
    } else if ([key isEqualToString: @"Armor"]) {
        return @"shield";
    } else if ([key isEqualToString: @"Ship Attack"]) {
        return @"attack";
    } else if ([key isEqualToString: @"Type"]) {
        return @"upType";
    }
    key = [key stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* lowerFirst = [[key substringToIndex: 1] lowercaseString];
    NSString* rest = [key substringFromIndex: 1];
    return [[lowerFirst stringByAppendingString: rest]stringByReplacingOccurrencesOfString: @" " withString: @""];
}


-(NSArray*)loadTabSeparatedFile:(NSString*)fileName error:(NSError**)error
{
    NSDictionary* colorMap = @{
        @"R":  @"red",
        @"G":  @"green",
        @"W":  @"white"
    };
    NSString* pathToDataFile = [_pathToDataFiles stringByAppendingPathComponent: [fileName stringByAppendingPathExtension: @"tsv"]];
    NSString* dataFileContents = [NSString stringWithContentsOfFile: pathToDataFile encoding: NSUTF8StringEncoding error: error];
    if (dataFileContents == nil) {
        return nil;
    }
    NSArray* lines = [dataFileContents componentsSeparatedByString: @"\n"];
    NSString* columnTitlesLine = lines.firstObject;
    NSArray* columnTitles = [columnTitlesLine componentsSeparatedByString: @"\t"];
    NSMutableArray* itemKeys = [[NSMutableArray alloc] initWithCapacity: 0];
    for (NSString* title in columnTitles) {
        [itemKeys addObject: makeKey(title)];
    }
    NSMutableArray* items = [NSMutableArray arrayWithCapacity: 0];
    for (NSInteger index = 1; index < lines.count; ++index) {
        NSString* line = lines[index];
        NSArray* parts = [line componentsSeparatedByString: @"\t"];
        NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity: 0];
        NSMutableArray* moves = [NSMutableArray arrayWithCapacity: 0];
        d[@"moves"] = moves;
        for (NSInteger keyIndex = 0; keyIndex < itemKeys.count; ++keyIndex) {
            if (keyIndex < parts.count) {
                NSString* key = itemKeys[keyIndex];
                if (key.length > 0) {
                    for (NSString* kind in @[@"turn", @"bank", @"comeAbout", @"reverse", @"straight"]) {
                        if ([key hasPrefix: kind]) {
                            int speed = [[key substringFromIndex: kind.length] intValue];
                            NSString* color = parts[keyIndex];
                            if (color.length > 0) {
                                if ([kind isEqualToString: @"turn"] || [kind isEqualToString: @"bank"]) {
                                    for (NSString* direction in @[@"left", @"right"]) {
                                        NSString* directionCode = [NSString stringWithFormat: @"%@-%@", direction, kind];
                                        [moves addObject: @{@"kind" : directionCode, @"speed": [NSNumber numberWithInt: speed], @"color": colorMap[color]}];
                                    }
                                } else if ([kind isEqualToString: @"comeAbout"]){
                                    [moves addObject: @{@"kind" : @"about", @"speed": [NSNumber numberWithInt: speed], @"color": colorMap[color]}];
                                } else if ([kind isEqualToString: @"reverse"]){
                                    [moves addObject: @{@"kind" : @"straight", @"speed": [NSNumber numberWithInt: -speed], @"color": colorMap[color]}];
                                } else if ([kind isEqualToString: @"straight"]){
                                    [moves addObject: @{@"kind" : @"straight", @"speed": [NSNumber numberWithInt: speed], @"color": colorMap[color]}];
                                }
                            }
                            key = nil;
                            break;
                        }
                    }
                    
                    if (key) {
                        if ([key isEqualToString: @"carry"]) {
                            int minCarry = 0;
                            int maxCarry = 0;
                            NSArray* carryParts = [parts[keyIndex] componentsSeparatedByString: @"-"];
                            if (carryParts.count > 1) {
                                minCarry = [carryParts[0] intValue];
                                maxCarry = [carryParts[1] intValue];
                            }
                            d[@"carry"] = @{@"min": [NSNumber numberWithInt: minCarry], @"max": [NSNumber numberWithInt: maxCarry]};
                        } else if ([key isEqualToString: @"upType"]) {
                            NSString* typeWithTags = parts[keyIndex];
                            NSArray* typeParts = [typeWithTags componentsSeparatedByString: @" - "];
                            d[key] = typeParts[0];
                        } else {
                            d[key] = parts[keyIndex];
                        }
                    }
                }
            }
        }
        d[@"set"] = @"core";
        [items addObject: d];
    }
    return [NSArray arrayWithArray: items];
}

-(void)loadItems:(NSArray*)items itemClass:(Class)itemClass entityName:(NSString*)entityName targetType:(NSString*)targetType
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: _managedObjectContext];
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);
    
    NSDictionary* attributes = [NSDictionary dictionaryWithDictionary: [entity attributesByName]];
    
    for (NSDictionary* d in items) {
        NSString* externalId = d[@"externalId"];
        if (externalId.length > 0) {
            id c = existingItemsLookup[externalId];
            
            if (c == nil) {
                c = [[itemClass alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
            } else {
                [existingItemsLookup removeObjectForKey: externalId];
            }
            
            [c setIsCraft: [targetType isEqualToString: @"craft"] ? @YES : @NO];
            
            for (NSString* key in d) {
                NSString* modifiedKey = key;
                
                NSAttributeDescription* desc = [attributes objectForKey: modifiedKey];
                
                if (desc != nil) {
                    id v = [d valueForKey: key];
                    NSInteger aType = [desc attributeType];
                    v = processAttribute(v, aType);
                    [c setValue: v forKey: modifiedKey];
                }
                
            }
            
            for (NSString* key in d) {
                if ([key isEqualToString: @"moves"]) {
                    NSString* shipClass = d[@"shipClass"];
                    DockShip* ship = (DockShip*)c;
                    DockShipClassDetails* shipClassDetails = ship.shipClassDetails;
                    if (shipClassDetails == nil) {
                        [ship updateShipClass: shipClass];
                        shipClassDetails = ship.shipClassDetails;
                    }
                    NSArray* m =  [d valueForKey: key];
                    [shipClassDetails updateManeuvers: m];
                } else if ([key isEqualToString: @"shipClass"]) {
                    DockShip* ship = (DockShip*)c;
                    NSString* shipClass =  [d valueForKey: key];
                    if (shipClass.length > 0) {
                        [ship updateShipClass: shipClass];
                    }
                } else if ([key isEqualToString: @"carry"]) {
                    id v = [d valueForKey: key];
                    [c setMinCarry: [v valueForKey:@"min"]];
                    [c setMaxCarry: [v valueForKey:@"max"]];
                } else if ([key isEqualToString: @"wingStrength"]) {
                    NSString* wingStrength = [d valueForKey: key];
                    NSString* title = [c title];
                    if (wingStrength.length > 0) {
                        [c setTitle: [NSString stringWithFormat: @"%@ (%@)", title, wingStrength]];
                        if ([[c cost] intValue] == 0) {
                            NSString* calcCostString = [d valueForKey: @"calcCost"];
                            NSNumber* calcCost = [NSNumber numberWithInt: [calcCostString intValue]];
                            [c setCost: calcCost];
                        }
                    }
                }
            }
        }
    }
}

-(void)loadUpgrades:(NSArray*)items itemClass:(Class)itemClass entityName:(NSString*)entityName targetType:(NSString*)targetType
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: _managedObjectContext];
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);
    
    NSDictionary* attributes = [NSDictionary dictionaryWithDictionary: [entity attributesByName]];
    
    for (NSDictionary* d in items) {
        NSString* externalId = d[@"externalId"];
        if (externalId.length > 0) {
            NSString* type = d[@"upType"];
            if ([type isEqualToString: targetType]) {
                id c = existingItemsLookup[externalId];
                
                if (c == nil) {
                    c = [[itemClass alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
                } else {
                    [existingItemsLookup removeObjectForKey: externalId];
                }
                
                for (NSString* key in d) {
                    NSString* modifiedKey = key;
                    
                    NSAttributeDescription* desc = [attributes objectForKey: modifiedKey];
                    
                    if (desc != nil) {
                        id v = [d valueForKey: key];
                        NSInteger aType = [desc attributeType];
                        v = processAttribute(v, aType);
                        [c setValue: v forKey: modifiedKey];
                    }
                    
                }
            }
        }
    }
}


-(BOOL)loadShips:(NSError**)error
{
    NSArray* items = [self loadTabSeparatedFile: @"ships" error: error];
    [self loadItems: items itemClass:[DockShip class] entityName: @"Ship" targetType: @"ship"];
    return YES;
}

-(BOOL)loadCraft:(NSError**)error
{
    NSArray* items = [self loadTabSeparatedFile: @"craft" error: error];
    [self loadItems: items itemClass:[DockShip class] entityName: @"Ship" targetType: @"craft"];
    return YES;
}

-(BOOL)loadUpgrades:(NSError**)error
{
    for (NSString* fileName in @[@"col_ship_upgrades", @"cylon_ship_upgrades"]) {
        NSArray* items = [self loadTabSeparatedFile: fileName error: error];
        if (items == nil) {
            return NO;
        }
        [self loadUpgrades: items itemClass:[DockCaptain class] entityName: @"Captain" targetType: @"Captain"];
        [self loadUpgrades: items itemClass:[DockTalent class] entityName: @"Talent" targetType: @"Talent"];
        [self loadUpgrades: items itemClass:[DockCrew class] entityName: @"Crew" targetType: @"Crew"];
        [self loadUpgrades: items itemClass:[DockTech class] entityName: @"Tech" targetType: @"Tech"];
        [self loadUpgrades: items itemClass:[DockWeapon class] entityName: @"Weapon" targetType: @"Weapon"];
    }
    return YES;
}

-(void)createSet
{
    DockSet* set = [DockSet setForId: @"core" context: _managedObjectContext];
    if (set == nil) {
        NSEntityDescription* entity = [NSEntityDescription entityForName: @"Set" inManagedObjectContext: _managedObjectContext];
        set = [[DockSet alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
        set.productName = @"Core";
        set.name = @"Core";
        set.externalId = @"core";
    }
}

-(BOOL)loadData:(NSError**)error
{
    [self createSet];
    if (![self loadShips: error]) {
        return NO;
    }
    if (![self loadCraft: error]) {
        return NO;
    }
    if (![self loadUpgrades: error]) {
        return NO;
    }
    return YES;
}

@end
