#import "DockDataLoader.h"

#import <Foundation/NSXMLParser.h>

#import "DockCaptain.h"
#import "DockCrew.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockResource.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockSquad.h"
#import "DockTalent.h"
#import "DockTech.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"
#import "DockWeapon.h"

@implementation DockDataLoader

-(id)initWithContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self != nil) {
        _managedObjectContext = context;
        _listElementNames = [NSSet setWithArray: @[@"Sets", @"Upgrades", @"Captains", @"Ships", @"Resources"]];
        _itemElementNames = [NSSet setWithArray: @[@"Set", @"Upgrade", @"Captain", @"Ship", @"Resource"]];
        _elementNameStack = [[NSMutableArray alloc] initWithCapacity: 0];
    }
    return self;
}


#if 0
-(NSDictionary*)convertNode:(NSXMLNode*)node
{
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity: 0];

    for (NSXMLNode* c in node.children) {
        [d setObject: [c objectValue] forKey: [c name]];
    }
    return [NSDictionary dictionaryWithDictionary: d];
}
#endif

-(NSString*)parentName
{
    NSString* parentName = nil;
    if (_elementNameStack.count > 1) {
        parentName = _elementNameStack[_elementNameStack.count - 2];
    }
    return parentName;
}

-(BOOL)isDataItem:(NSString*)elementName
{
    if (![_itemElementNames containsObject: elementName]) {
        return NO;
    }

    if ([elementName isEqualToString: @"Set"]) {
        NSString* parentName = [self parentName];
        if (![parentName isEqualToString: @"Sets"] ) {
            return NO;
        }
    }

    return YES;
}

-(BOOL)isList:(NSString*)elementName
{
    if (![_listElementNames containsObject: elementName]) {
        return NO;
    }

    if ([elementName isEqualToString: @"Set"]) {
        NSString* parentName = [self parentName];
        if (![parentName isEqualToString: @"Sets"] ) {
            return NO;
        }
    }

    return YES;
}

static id processAttribute(id v, NSInteger aType)
{
    switch (aType) {
    case NSInteger16AttributeType:
        v = [NSNumber numberWithInt: [v intValue]];
        break;

    case NSBooleanAttributeType:
        v = [NSNumber numberWithBool: [v isEqualToString: @"Y"]];
        break;

    case NSStringAttributeType:
        v = [v stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        break;
    }
    return v;
}

static NSMutableDictionary* createExistingItemsLookup(NSManagedObjectContext* context, NSEntityDescription* entity)
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity: entity];
    NSError* err;
    NSArray* existingItems = [context executeFetchRequest: request error: &err];
    NSMutableDictionary* existingItemsLookup = [NSMutableDictionary dictionaryWithCapacity: existingItems.count];

    for (id existingItem in existingItems) {
        NSString* externalId = [existingItem externalId];
        if (externalId) {
            existingItemsLookup[externalId] = existingItem;
        }
    }

    return existingItemsLookup;
}

-(void)loadItems:(NSArray*)items itemClass:(Class)itemClass entityName:(NSString*)entityName targetType:(NSString*)targetType
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: _managedObjectContext];
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);

    NSDictionary* attributes = [entity attributesByName];

    for (NSDictionary* d in items) {
        NSString* nodeType = d[@"Type"];

        if (targetType == nil || [nodeType isEqualToString: targetType]) {
            NSString* externalId = d[@"Id"];
            id c = existingItemsLookup[externalId];

            if (c == nil) {
                c = [[itemClass alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
            } else {
                [existingItemsLookup removeObjectForKey: externalId];
            }

            for (NSString* key in d) {
                NSString* modifiedKey;

                if ([key isEqualToString: @"Id"]) {
                    modifiedKey = @"externalId";
                } else if ([key isEqualToString: @"Battlestations"]) {
                    modifiedKey = @"battleStations";
                } else if ([key isEqualToString: @"Type"]) {
                    modifiedKey = @"upType";
                } else {
                    modifiedKey = makeKey(key);
                }

                NSAttributeDescription* desc = [attributes objectForKey: modifiedKey];

                if (desc != nil) {
                    id v = [d valueForKey: key];
                    NSInteger aType = [desc attributeType];
                    v = processAttribute(v, aType);
                    [c setValue: v forKey: modifiedKey];
                }
            }
            NSString* setValue = [d objectForKey: @"Set"];
            NSArray* sets = [setValue componentsSeparatedByString: @","];
            for (NSString* rawSet in sets) {
                NSString* setId = [rawSet stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                DockSet* theSet = [DockSet setForId:setId context:_managedObjectContext];
                [theSet addItemsObject: c];
            }
        }
    }
}

static NSString* makeKey(NSString *key)
{
    NSString* lowerFirst = [[key substringToIndex: 1] lowercaseString];
    NSString* rest = [key substringFromIndex: 1];
    return [lowerFirst stringByAppendingString: rest];
}

-(void)loadSets:(NSArray*)sets
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Set" inManagedObjectContext: _managedObjectContext];
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);

    for (NSDictionary* oneSet in sets) {
        NSString* externalId = [oneSet objectForKey: @"id"];
        DockSet* c = existingItemsLookup[externalId];

        if (c == nil) {
            c = [[DockSet alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
        }

        [c setExternalId: externalId];
        [c setProductName: [oneSet objectForKey: @"ProductName"]];
        [c setName: [oneSet objectForKey: @"overallSetName"]];
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser;
{
    NSLog(@"parserDidStartDocument %@", parser);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"foundNotationDeclarationWithName %@", parser);
}
    // sent when the parser has completed parsing. If this is encountered, the parse was successful.

// DTD handling methods for various declarations.
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
    NSLog(@"foundNotationDeclarationWithName %@", name);
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
    NSLog(@"foundUnparsedEntityDeclarationWithName %@", name);
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue;
{
    NSLog(@"foundAttributeDeclarationWithName %@", attributeName);
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
    NSLog(@"foundElementDeclarationWithName %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
    NSLog(@"foundExternalEntityDeclarationWithName %@", name);
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
    NSLog(@"foundExternalEntityDeclarationWithName %@", name);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [_elementNameStack addObject: elementName];
    if (attributeDict.count > 0) {
        _currentAttributes = attributeDict;
    } else {
        _currentAttributes = nil;
    }
    if ([self isList: elementName]) {
        if (_currentList != nil) {
            NSLog(@"starting a new list element before finishing the last");
        }
        _currentList = [[NSMutableArray alloc] initWithCapacity: 0];
    } else if ([self isDataItem: elementName]) {
        if (_currentElement != nil) {
            NSLog(@"starting a new item %@ before finishing the last", elementName);
        }
        _currentElement = [[NSMutableDictionary alloc] initWithCapacity: 0];
    }
    _currentText = [[NSMutableString alloc] init];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([self isList: elementName]) {
        if (_currentList != nil) {
            _parsedData[elementName] = _currentList;
            _currentList = nil;
        } else {
            NSLog(@"ending a list element before starting it");
        }
    } else if ([self isDataItem: elementName]) {
        if (_currentElement == nil) {
            NSLog(@"ending an item before starting it");
        }
        if (_currentAttributes != nil) {
            [_currentElement addEntriesFromDictionary: _currentAttributes];
            if (_currentText != nil) {
                [_currentElement setObject: _currentText forKey: @"ProductName"];
            }
        }
        [_currentList addObject: _currentElement];
        _currentElement = nil;
    } else {
        if (_currentText != nil) {
            NSString* trimmed = [_currentText stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (_currentAttributes != nil) {
                _currentElement[@"ProductName"] = trimmed;
            } else {
                _currentElement[elementName] = trimmed;
            }
        } else {
            NSLog(@"ending element %@ before starting", elementName);
        }
        _currentText = nil;
    }
    [_elementNameStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
    NSLog(@"didStartMappingPrefix %@", prefix);
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
    NSLog(@"didEndMappingPrefix %@", prefix);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentText appendString: string];
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    NSLog(@"foundIgnorableWhitespace %@", whitespaceString);
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    NSLog(@"foundProcessingInstructionWithTarget %@", target);
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    NSLog(@"foundComment %@", comment);
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    NSLog(@"foundCDATA %@", CDATABlock);
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
{
    NSLog(@"resolveExternalEntityName %@", name);
    return nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"parseErrorOccurred %@", parseError);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"validationErrorOccurred %@", validationError);
}

-(NSDictionary*)loadDataFile:(NSError**)error
{
    NSString* file = [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];

    _parsedData = [[NSMutableDictionary alloc] initWithCapacity: 0];
    NSURL* furl = [NSURL fileURLWithPath: file];

    if (!furl) {
        NSLog(@"Can't create an URL from file %@.", file);
        return nil;
    }

    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL: [NSURL fileURLWithPath: file]];
    [parser setDelegate:self];
    [parser parse];

    return _parsedData;
}

-(NSSet*)validateSpecials
{
    NSSet* specials = allAttributes(_managedObjectContext, @"Upgrade", @"Special");
    specials = [specials setByAddingObjectsFromSet: allAttributes(_managedObjectContext, @"Resource", @"Special")];
    NSArray* handledSpecials = @[
        @"BaselineTalentCostToThree",
        @"CrewUpgradesCostOneLess",
        @"costincreasedifnotromulansciencevessel",
        @"WeaponUpgradesCostOneLess",
        @"costincreasedifnotbreen",
        @"UpgradesIgnoreFactionPenalty",
        @"CaptainAndTalentsIgnoreFactionPenalty",
        @"PenaltyOnShipOtherThanDefiant",
        @"PlusFivePointsNonJemHadarShips",
        @"NoPenaltyOnFederationOrBajoranShip",
        @"OneDominionUpgradeCostsMinusTwo",
        @"OnlyJemHadarShips"
                               ];
    NSMutableSet* unhandledSpecials = [[NSMutableSet alloc] initWithSet: specials];
    [unhandledSpecials minusSet: [NSSet setWithArray: handledSpecials]];
    return unhandledSpecials;
}

-(BOOL)loadData:(NSError**)error
{
    NSDictionary* xmlData = [self loadDataFile: error];

    if (xmlData == nil) {
        return NO;
    }

    [self loadSets: xmlData[@"Sets"]];
    [self loadItems: xmlData[@"Ships"] itemClass: [DockShip class] entityName: @"Ship" targetType: nil];
    [self loadItems: xmlData[@"Captains"] itemClass: [DockCaptain class] entityName: @"Captain" targetType: nil];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockWeapon class] entityName: @"Weapon" targetType: @"Weapon"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockTalent class] entityName: @"Talent" targetType: @"Talent"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockCrew class] entityName: @"Crew" targetType: @"Crew"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockTech class] entityName: @"Tech" targetType: @"Tech"];
    [self loadItems: xmlData[@"Resources"] itemClass: [DockResource class] entityName: @"Resource" targetType: @"Resource"];

    return YES;
}

@end
