#import "DockViperDataLoader.h"

#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"
#import "DockSet+Addons.h"
#import "DockUtils.h"

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
    } else if ([key isEqualToString: @"Evade"]) {
        return @"evasiveManeuvers";
    } else if ([key isEqualToString: @"Type"]) {
        return @"shipClass";
    } else if ([key isEqualToString: @"Armor"]) {
        return @"shield";
    } else if ([key isEqualToString: @"Ship Attack"]) {
        return @"attack";
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
                                }
                            }
                            key = nil;
                            break;
                        }
                    }
                    
                    if (key) {
                        d[key] = parts[keyIndex];
                    }
                }
            }
        }
        d[@"set"] = @"core";
        d[@"externalId"] = d[@"title"];
        [items addObject: d];
    }
    NSLog(@"item = %@", items);
    return [NSArray arrayWithArray: items];
}

-(void)loadItems:(NSArray*)items itemClass:(Class)itemClass entityName:(NSString*)entityName targetType:(NSString*)targetType
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: _managedObjectContext];
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);
    
    NSDictionary* attributes = [NSDictionary dictionaryWithDictionary: [entity attributesByName]];
    
    for (NSDictionary* d in items) {
        NSString* nodeType = d[@"Type"];
        
        if (targetType == nil || [nodeType isEqualToString: targetType]) {
            NSString* externalId = d[@"externalId"];
            if (externalId.length > 0) {
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
                
                for (NSString* key in d) {
                    if ([key isEqualToString: @"maneuvers"]) {
                        DockShipClassDetails* shipClassDetails = (DockShipClassDetails*)c;
                        NSArray* m =  [d valueForKey: key];
                        [shipClassDetails updateManeuvers: m];
                    } else if ([key isEqualToString: @"shipClass"]) {
                        DockShip* ship = (DockShip*)c;
                        NSString* shipClass =  [d valueForKey: key];
                        [ship updateShipClass: shipClass];
                    }
                }
                
                if ([c isKindOfClass: [DockSetItem class]]) {
                    NSString* setValue = [d objectForKey: @"set"];
                    NSArray* sets = [setValue componentsSeparatedByString: @","];
                    
                    NSSet* existingSets = [NSSet setWithSet: [c sets]];
                    for (DockSet* set in existingSets) {
                        if (![sets containsObject: set.externalId]) {
                            [set removeItemsObject: c];
                        }
                    }
                    
                    for (NSString* rawSet in sets) {
                        NSString* setId = [rawSet stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        DockSet* theSet = [DockSet setForId: setId context: _managedObjectContext];
                        [theSet addItemsObject: c];
                    }
                }
            }
        }
    }
}


-(BOOL)loadShips:(NSError**)error
{
    NSArray* items = [self loadTabSeparatedFile: @"ships" error: error];
    [self loadItems: items itemClass:[DockShip class] entityName: @"Ship" targetType: nil];
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
    return YES;
}

@end
