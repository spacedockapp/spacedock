#import "DockDataLoader.h"

#import <.h>

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
    }
    return self;
}


-(NSDictionary*)convertNode:(NSXMLNode*)node
{
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity: 0];

    for (NSXMLNode* c in node.children) {
        [d setObject: [c objectValue] forKey: [c name]];
    }
    return [NSDictionary dictionaryWithDictionary: d];
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

-(void)loadItems:(NSXMLDocument*)xmlDoc itemClass:(Class)itemClass entityName:(NSString*)entityName xpath:(NSString*)xpath targetType:(NSString*)targetType
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: _managedObjectContext];
    NSError* err;
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);

    NSArray* nodes = [xmlDoc nodesForXPath: xpath error: &err];
    NSDictionary* attributes = [entity attributesByName];

    for (NSXMLNode* oneNode in nodes) {
        NSDictionary* d = [self convertNode: oneNode];
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

-(void)loadSets:(NSXMLDocument*)xmlDoc
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Set" inManagedObjectContext: _managedObjectContext];
    NSError* err;
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);
    NSArray* elements = [xmlDoc nodesForXPath: @"/Data/Sets/Set" error: &err];

    for (NSXMLElement* oneElement in elements) {
        NSString* externalId = [[oneElement attributeForName: @"id"] stringValue];
        DockSet* c = existingItemsLookup[externalId];

        if (c == nil) {
            c = [[DockSet alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
        }

        [c setExternalId: externalId];
        [c setProductName: [oneElement stringValue]];
        NSString* name = [[oneElement attributeForName: @"overallSetName"] stringValue];
        [c setName: name];
    }

    for (DockSet* set in [DockSet allSets: _managedObjectContext]) {
        [set addObserver: self forKeyPath: @"include" options: 0 context: 0];
    }
}

-(NSXMLDocument*)loadDataFile:(NSError**)error
{
    NSString* file = [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];
    NSXMLDocument* xmlDoc;
    NSURL* furl = [NSURL fileURLWithPath: file];

    if (!furl) {
        NSLog(@"Can't create an URL from file %@.", file);
        return nil;
    }

    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL: furl
                                                  options: (NSXMLNodePreserveWhitespace | NSXMLNodePreserveCDATA)
                                                    error: error];

    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL: furl
                                                      options: NSXMLDocumentTidyXML
                                                        error: error];
    }

    return xmlDoc;
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
    NSXMLDocument* xmlDoc = [self loadDataFile: error];

    if (xmlDoc == nil) {
        return NO;
    }

    [self loadSets: xmlDoc];
    [self loadItems: xmlDoc itemClass: [DockShip class] entityName: @"Ship" xpath: @"/Data/Ships/Ship" targetType: nil];
    [self loadItems: xmlDoc itemClass: [DockCaptain class] entityName: @"Captain" xpath: @"/Data/Captains/Captain" targetType: nil];
    [self loadItems: xmlDoc itemClass: [DockWeapon class] entityName: @"Weapon" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Weapon"];
    [self loadItems: xmlDoc itemClass: [DockTalent class] entityName: @"Talent" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Talent"];
    [self loadItems: xmlDoc itemClass: [DockCrew class] entityName: @"Crew" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Crew"];
    [self loadItems: xmlDoc itemClass: [DockTech class] entityName: @"Tech" xpath: @"/Data/Upgrades/Upgrade" targetType: @"Tech"];
    [self loadItems: xmlDoc itemClass: [DockResource class] entityName: @"Resource" xpath: @"/Data/Resources/Resource" targetType: @"Resource"];

    return YES;
}

@end
