#import "DockDataFileLoader.h"

#import <Foundation/NSXMLParser.h>

#import "DockAdmiral.h"
#import "DockBorg+Addons.h"
#import "DockCaptain+Addons.h"
#import "DockConstants.h"
#import "DockCrew.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedShip.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockFlagship.h"
#import "DockFleetCaptain.h"
#import "DockOfficer.h"
#import "DockResource.h"
#import "DockReference.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockShipClassDetails+Addons.h"
#import "DockSquad+Addons.h"
#import "DockSquad.h"
#import "DockSquadronUpgrade.h"
#import "DockResourceUpgrade.h"
#import "DockTalent.h"
#import "DockTech.h"
#import "DockUpgrade+Addons.h"
#import "DockUtils.h"
#import "DockWeapon.h"
#import "ISO8601DateFormatter.h"

@interface DockDataFileLoader () {
    BOOL _force;
    BOOL _versionOnly;
}
@end

@implementation DockDataFileLoader

-(id)initWithContext:(NSManagedObjectContext*)context version:(NSString*)version
{
    self = [super init];

    if (self != nil) {
        [self reset];
        _managedObjectContext = context;
        _currentVersion = version;
        if ([DockUpgrade allFactions: _managedObjectContext] == 0) {
            _currentVersion = @"";
        }
    }

    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

-(void)reset
{
    _listElementNames = [NSSet setWithArray: @[@"Sets", @"Upgrades", @"Captains", @"Admirals", @"Ships", @"Resources", @"Maneuvers", @"ShipClassDetails", @"Flagships", @"FleetCaptains", @"Officers", @"ReferenceItems"]];
    _itemElementNames = [NSSet setWithArray: @[@"Set", @"Upgrade", @"Captain", @"Admiral", @"Ship", @"Resource", @"Maneuver", @"ShipClassDetail", @"Flagship", @"FleetCaptain", @"Officer", @"Reference"]];
    _elementNameStack = [[NSMutableArray alloc] initWithCapacity: 0];
    _listStack = [[NSMutableArray alloc] initWithCapacity: 0];
    _elementStack = [[NSMutableArray alloc] initWithCapacity: 0];
    _currentVersion = @"";
    _versionOnly = NO;
    _force = NO;
}

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

        if (![parentName isEqualToString: @"Sets"]) {
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

        if (![parentName isEqualToString: @"Sets"]) {
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

    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithDictionary: [entity attributesByName]];
    NSEntityDescription* superEntity = entity.superentity;
    while (superEntity != nil) {
        NSDictionary* superAttributes = [NSDictionary dictionaryWithDictionary: [superEntity attributesByName]];
        [attributes addEntriesFromDictionary: superAttributes];
        superEntity = superEntity.superentity;
    }

    for (NSDictionary* d in items) {
        NSString* nodeType = d[@"Type"];
        if (targetType == nil || nodeType == nil || [nodeType isEqualToString: targetType]) {
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
                } else if ([key isEqualToString: @"Type"] && [c isKindOfClass: [DockUpgrade class]]) {
                    modifiedKey = @"upType";
                } else if ([key isEqualToString:@"Squadron"]) {
                    modifiedKey = @"squadronUpgrade";
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

            for (NSString* key in d) {
                if ([key isEqualToString: @"Maneuvers"]) {
                    DockShipClassDetails* shipClassDetails = (DockShipClassDetails*)c;
                    NSArray* m =  [d valueForKey: key];
                    [shipClassDetails updateManeuvers: m];
                } else if ([key isEqualToString: @"ShipClass"]) {
                    DockShip* ship = (DockShip*)c;
                    NSString* shipClass =  [d valueForKey: key];
                    [ship updateShipClass: shipClass];
                } else if ([key isEqualToString: @"ShipClassDetailsId"]) {
                    DockShip* ship = (DockShip*)c;
                    NSString* shipClassDetailsId =  [d valueForKey: key];
                    [ship updateShipClassWithId: shipClassDetailsId];
                }
            }

            if ([c isKindOfClass: [DockSetItem class]]) {
                NSString* setValue = [d objectForKey: @"Set"];
                NSArray* sets = [setValue componentsSeparatedByString: @","];

                NSSet* existingSets = [NSSet setWithSet: [c sets]];
                for (DockSet* set in existingSets) {
                    if (![sets containsObject: set.externalId]) {
                        [set removeItemsObject: c];
                    }
                }

                for (NSString* rawSet in sets) {
                    NSString* setId = [rawSet stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    DockSet* theSet = [_allSets objectForKey: setId];
                    if (theSet != nil) {
                        [theSet addItemsObject: c];
                    } else {
                        NSLog(@"Failed to find set for id %@", setId);
                    }
                }
            }
        }
    }
}

static NSString* makeKey(NSString* key)
{
    NSString* lowerFirst = [[key substringToIndex: 1] lowercaseString];
    NSString* rest = [key substringFromIndex: 1];
    return [lowerFirst stringByAppendingString: rest];
}

-(void)loadSets:(NSArray*)sets
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Set" inManagedObjectContext: _managedObjectContext];
    NSMutableDictionary* existingItemsLookup = createExistingItemsLookup(_managedObjectContext, entity);
    ISO8601DateFormatter* dateFormatter = [[ISO8601DateFormatter alloc] init];

    for (NSDictionary* oneSet in sets) {
        NSString* externalId = [oneSet objectForKey: @"id"];
        DockSet* c = existingItemsLookup[externalId];

        if (c == nil) {
            c = [[DockSet alloc] initWithEntity: entity insertIntoManagedObjectContext: _managedObjectContext];
        }

        [c setExternalId: externalId];
        [c setProductName: [oneSet objectForKey: @"ProductName"]];
        [c setName: [oneSet objectForKey: @"overallSetName"]];
        NSString* releaseDateString = [oneSet objectForKey: @"releaseDate"];
        NSDate* releaseDate = [dateFormatter dateFromString: releaseDateString];
        [c setReleaseDate: releaseDate];
    }

    NSArray* allSets = [DockSet allSets: _managedObjectContext];
    NSMutableDictionary* allSetsDictionary = [[NSMutableDictionary alloc] initWithCapacity: sets.count];
    for(DockSet* set in allSets) {
        [allSetsDictionary setObject: set forKey: set.externalId];
    }
    _allSets = [NSDictionary dictionaryWithDictionary: allSetsDictionary];
}

-(void)parserDidStartDocument:(NSXMLParser*)parser;
{
}

-(void)parserDidEndDocument:(NSXMLParser*)parser
{
}

// sent when the parser has completed parsing. If this is encountered, the parse was successful.

// DTD handling methods for various declarations.
-(void)parser:(NSXMLParser*)parser foundNotationDeclarationWithName:(NSString*)name publicID:(NSString*)publicID systemID:(NSString*)systemID
{
}

-(void)parser:(NSXMLParser*)parser foundUnparsedEntityDeclarationWithName:(NSString*)name publicID:(NSString*)publicID systemID:(NSString*)systemID notationName:(NSString*)notationName
{
}

-(void)parser:(NSXMLParser*)parser foundAttributeDeclarationWithName:(NSString*)attributeName forElement:(NSString*)elementName type:(NSString*)type defaultValue:(NSString*)defaultValue;
{
}

-(void)parser:(NSXMLParser*)parser foundElementDeclarationWithName:(NSString*)elementName model:(NSString*)model
{
}

-(void)parser:(NSXMLParser*)parser foundInternalEntityDeclarationWithName:(NSString*)name value:(NSString*)value
{
}

-(void)parser:(NSXMLParser*)parser foundExternalEntityDeclarationWithName:(NSString*)name publicID:(NSString*)publicID systemID:(NSString*)systemID
{
}

-(void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
    [_elementNameStack addObject: elementName];

    if (attributeDict.count > 0) {
        _currentAttributes = attributeDict;
    } else {
        _currentAttributes = nil;
    }

    if ([self isList: elementName]) {
        if (_currentList != nil) {
            [_listStack addObject: _currentList];
        }

        _currentList = [[NSMutableArray alloc] initWithCapacity: 0];
    } else if ([self isDataItem: elementName]) {
        if (_currentElement != nil) {
            [_elementStack addObject: _currentElement];
        }

        _currentElement = [[NSMutableDictionary alloc] initWithCapacity: 0];
    } else if ([elementName isEqualToString: @"Data"]) {
        self.dataVersion = _currentAttributes[@"version"];
        if (_versionOnly) {
            [parser abortParsing];
        } else if (!_force && [_dataVersion isEqualToString: _currentVersion] && _dataVersion.length != 0) {
            _versionMatched = YES;
            [parser abortParsing];
        }
    }

    _currentText = [[NSMutableString alloc] init];
}

-(void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName
{
    if ([self isList: elementName]) {
        if (_currentList != nil) {
            if ([elementName isEqualToString: @"Maneuvers"]) {
                _currentElement[elementName] = _currentList;
            } else {
                _parsedData[elementName] = _currentList;
            }

            _currentList = [_listStack lastObject];

            if (_currentList) {
                [_listStack removeLastObject];
            }
        } else {
            NSLog(@"ending a list element before starting it");
        }
    } else if ([self isDataItem: elementName]) {
        if (_currentElement == nil) {
            NSLog(@"ending an item before starting it");
        } else {
            if (_currentAttributes != nil) {
                [_currentElement addEntriesFromDictionary: _currentAttributes];

                if (_currentText != nil && [elementName isEqualToString: @"Set"]) {
                    NSString* trimmed = [_currentText stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [_currentElement setObject: trimmed forKey: @"ProductName"];
                }
            }

            [_currentList addObject: _currentElement];
            _currentElement = [_elementStack lastObject];

            if (_currentElement) {
                [_elementStack removeLastObject];
            }
        }
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

-(void)parser:(NSXMLParser*)parser didStartMappingPrefix:(NSString*)prefix toURI:(NSString*)namespaceURI
{
}

-(void)parser:(NSXMLParser*)parser didEndMappingPrefix:(NSString*)prefix
{
}

-(void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    [_currentText appendString: string];
}

-(void)parser:(NSXMLParser*)parser foundIgnorableWhitespace:(NSString*)whitespaceString
{
}

-(void)parser:(NSXMLParser*)parser foundProcessingInstructionWithTarget:(NSString*)target data:(NSString*)data
{
}

-(void)parser:(NSXMLParser*)parser foundComment:(NSString*)comment
{
}

-(void)parser:(NSXMLParser*)parser foundCDATA:(NSData*)CDATABlock
{
}

-(NSData*)parser:(NSXMLParser*)parser resolveExternalEntityName:(NSString*)name systemID:(NSString*)systemID
{
    return nil;
}

-(void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
    if (!_versionMatched) {
        NSLog(@"parseErrorOccurred %@", parseError);
    }
}

-(void)parser:(NSXMLParser*)parser validationErrorOccurred:(NSError*)validationError
{
    NSLog(@"validationErrorOccurred %@", validationError);
    _parsedData = nil;
}

-(NSDictionary*)loadDataFile:(NSString*)pathToDataFile force:(BOOL)force error:(NSError**)error
{
    _parsedData = [[NSMutableDictionary alloc] initWithCapacity: 0];
    NSURL* furl = [NSURL fileURLWithPath: pathToDataFile];

    if (!furl) {
        NSLog(@"Can't create an URL from file %@.", pathToDataFile);
        return nil;
    }

    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL: furl];
    [parser setDelegate: self];
    [parser parse];

    return _parsedData;
}

-(void)fixErrors
{
    NSArray* allSquads = [DockSquad allSquads: _managedObjectContext];
    DockBorg* wrongSeven = [DockBorg borgForId: @"seven_of_nine_71283" context: _managedObjectContext];
    if (wrongSeven != nil) {
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: wrongSeven];
        }
        [_managedObjectContext deleteObject: wrongSeven];
    }
    DockUpgrade* extraFed = [DockCaptain captainForId: @"federation_captain_71280" context: _managedObjectContext];
    if (extraFed != nil) {
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: extraFed];
        }
        [_managedObjectContext deleteObject: extraFed];
    }
    
    DockUpgrade* wrongLure = [DockUpgrade upgradeForId:@"lure_71805" context: _managedObjectContext];
    if (wrongLure != nil && [wrongLure isTech]) {
        for (DockSquad* s in allSquads) {
            [s purgeUpgrade: wrongLure];
        }
        [_managedObjectContext deleteObject: wrongLure];
    }
    NSArray* upgIO = [DockUpgrade findUpgrades:@"Impulse Overload" context: _managedObjectContext];
    if (upgIO.count > 2) {
        BOOL duperemoved = NO;
        for (DockUpgrade* wrongImpulseOverload in upgIO) {
            if ([wrongImpulseOverload.externalId isEqualToString:@"impulse_overload_oparenaprize"] && !duperemoved) {
                [_managedObjectContext deleteObject: wrongImpulseOverload];
                duperemoved = YES;
            }
        }
    }
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
        @"OnlyJemHadarShips",
        @"PenaltyOnShipOtherThanKeldonClass",
        @"addonetechslot",
        @"OnlyForRomulanScienceVessel",
        @"OnlyForRaptorClassShips",
        @"OnlyForKlingonCaptain",
        @"AddTwoWeaponSlots",
        @"AddTwoCrewSlotsDominionCostBonus",
        @"AddsHiddenTechSlot",
        @"PlusFiveOnNonSpecies8472",
        @"OnlySpecies8472Ship",
        @"OnlyBajoranCaptain",
        @"OnlyKazonShip",
        @"PlusFiveForNonKazon",
        @"OnlyBorgShip",
        @"OnlyVoyager",
        @"AddsOneWeaponOneTech",
        @"OnlyTholianShip",
        @"OnlyTholianCaptain",
        @"OnlyVulcanCaptainVulcanShip",
        @"PhaserStrike",
        @"CostPlusFiveExceptBajoranInterceptor",
        @"Add_Crew_1",
        @"OnlyBorgCaptain",
        @"VulcanAndFedTechUpgradesMinus2",
        @"combat_vessel_variant_71508",
        @"lore_71522",
        @"hugh_71522",
        @"sakonna_gavroche",
        @"OnlyDominionCaptain",
        @"OnlyFederationShip",
        @"PlusFiveIfNotBorgShip",
        @"OnlyBattleshipOrCruiser",
        @"NoMoreThanOnePerShip",
        @"OnlyHull3OrLess",
        @"NoPenaltyOnFederationShip",
        @"PlusFiveIfNotRaven",
        @"TechUpgradesCostOneLess",
        @"addoneweaponslot",
        @"add_one_tech_no_faction_penalty_on_vulcan",
        @"ony_federation_ship_limited",
        @"only_vulcan_ship",
        @"not_with_hugh",
        @"only_suurok_class_limited_weapon_hull_plus_1",
        @"PlusFiveIfNotGalaxyIntrepidSovereign",
        @"AddOneWeaponAllKazonMinusOne",
        @"PlusFourIfNotPredatorClass",
        @"PlusFiveIfNotMirrorUniverse",
        @"OnlyFerengiCaptainFerengiShip",
        @"OnlyFerengiShip",
        @"AllUpgradesMinusOneOnIndepedentShip",
        @"OnlyFedShipHV4CostPWVP1",
        @"OnlyBorgShipAndNoMoreThanOnePerShip",
        @"OnlyNonBorgShipAndNonBorgCaptain",
        @"OnlyRemanWarbird",
        @"AddOneBorgSlot",
        @"PlusFiveIfNotRemanWarbird",
        @"OnlyKlingonBirdOfPrey",
        @"addonetalentslot",
        @"not_with_jean_luc_picard",
        @"PlusFiveIfSkillOverFive",
        @"PlusFiveIfNotRegentsFlagship",
        @"PlusFivePointsNonHirogen",
        @"AddHiddenWeapon",
        @"NoPenaltyOnKlingonShip",
        @"OnlyRomulanShip",
        @"OnlyRomulanCaptain",
        @"OnlyRomulanCaptainShip",
        @"PlusFiveIfNotRomulan",
        @"PlusFourIfNotGornRaider",
        @"OnlyDominionShip",
        @"OnlyDominionHV4",
        @"ony_mu_ship_limited",
        @"CaptainIgnoresPenalty",
        @"OnlyBajoran",
        @"ony_federation_ship_limited3",
        @"RomulanHijackers",
        @"OnlyKlingon",
        @"PlusFiveIfNotKlingon",
        @"Plus4NotPrometheus",
        @"OnlyKlingonCaptainShip",
        @"limited_max_weapon_3",
        @"OnlyDderidexAndNoMoreThanOnePerShip",
        @"OnlyFederationCaptainShip",
        @"Add2HiddenCrew5",
        @"KTemoc",
        @"Plus3NotKlingonAndNoMoreThanOnePerShip",
        @"OnlyIntrepidAndNoMoreThanOnePerShip",
        @"Plus2NotRomulanAndNoMoreThanOnePerShip",
        @"OnlyGrandNagusTalent",
        @"Hull4NoRearPlus5NonFed",
        @"AddTwoWeaponSlotsAndNoMoreThanOnePerShip",
        @"no_faction_penalty_on_vulcan",
        @"limited_max_weapon_3AndPlus5NonFed",
        @"Plus5NotDominionAndNoMoreThanOnePerShip",
        @"Plus5NotKlingon",
        @"Plus5NotXindi",
        @"OnlyTalShiarTalent",
        @"OnlyBajoranFederation",
        @"Plus4NotVulcan",
        @"OnlyKazonCaptainShip",
        @"Plus5NotFederationNoMoreThanOnePerShip",
        @"Plus3NotFederationNoMoreThanOnePerShip",
        @"costincreasedifnotromulansciencevesselAndNoMoreThanOnePerShip",
        @"OnlySecretResearchTalent",
        @"KlingonUpgradesCostOneLess",
        @"OnlyXindi",
        @"Add3FedTech4Less",
        @"Plus5NotKazonNoMoreThanOnePerShip",
        @"NoPenaltyOnTalent",
        @"OneRomulanTalentDiscIfFleetHasRomulan",
        @"OnlyBajoranCaptainShip",
        @"TwoBajoranTalents",
        @"RemanBodyguardsLess2",
        @"PlusFiveNotKlingonAndMustHaveComeAbout",
        @"AddOneTechMinus1",
        @"MustHaveBS",
        @"OPSPlusFiveNotRomulan",
        @"OnlyKlingonTalent",
        @"BSVT",
        @"OnlyBorgQueen",
        @"addoneweaponslotfortorpedoes",
        @"FedCrewUpgradesCostOneLess",
        @"KuvahMagh2Less",
        @"OPSPlus4NotXindi",
        @"OPSPlus5NotXindi",
        @"OnlyXindiCaptainShip",
        @"OnlyKlingonORRomulanCaptainShip",
        @"OnlyLBCaptain",
        @"OnlyFedShipHV4CostPWV",
        @"Ship2LessAndUpgrades1Less",
        @"addoneweaponslot1xindi2less",
        @"OnlyXindiANDCostPWV",
        @"Hull4",
        @"Hull3",
        @"OPSHull4",
        @"OPSHull3",
        @"CostPWV"
                               ];
    NSMutableSet* unhandledSpecials = [[NSMutableSet alloc] initWithSet: specials];
    [unhandledSpecials minusSet: [NSSet setWithArray: handledSpecials]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'OnlyShipClass_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'Plus3NotShipClass_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'Plus3NotShip_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'Plus4NotShipClass_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'Plus4NotShip_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'Plus5NotShipClass_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'Plus5NotShip_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'Plus6NotShipClass_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'Plus6NotShip_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'OnlyShip_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'NoMoreThanOnePerShip'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'OPSOnlyShipClass_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'OPSPlus5NotShipClass_'"]];
    [unhandledSpecials filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF BEGINSWITH 'OPSPlus3NotShipClass_'"]];

#if TARGET_IPHONE_SIMULATOR
    if (unhandledSpecials.count > 0) {
        NSLog(@"Unhandled specials: %@",[unhandledSpecials.allObjects componentsJoinedByString:@", "]);
    } else {
        NSLog(@"All specials handled");
    }
#endif
    
    return unhandledSpecials;
}

-(BOOL)loadData:(NSString*)pathToDataFile force:(BOOL)force error:(NSError**)error;
{
    _versionOnly = NO;
    
    [self fixErrors];

    NSDictionary* xmlData = [self loadDataFile: pathToDataFile force: force error:error];

    if (xmlData == nil) {
        return NO;
    }

    if (xmlData.count == 0) {
        return YES;
    }

    [self loadSets: xmlData[@"Sets"]];
    [self loadItems: xmlData[@"ShipClassDetails"] itemClass: [DockShipClassDetails class] entityName: @"ShipClassDetails" targetType: nil];
    [self loadItems: xmlData[@"Ships"] itemClass: [DockShip class] entityName: @"Ship" targetType: nil];
    [self loadItems: xmlData[@"Captains"] itemClass: [DockCaptain class] entityName: @"Captain" targetType: nil];
    [self loadItems: xmlData[@"Admirals"] itemClass: [DockAdmiral class] entityName: @"Admiral" targetType: @"Admiral"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockWeapon class] entityName: @"Weapon" targetType: @"Weapon"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockTalent class] entityName: @"Talent" targetType: @"Talent"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockCrew class] entityName: @"Crew" targetType: @"Crew"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockTech class] entityName: @"Tech" targetType: @"Tech"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockBorg class] entityName: @"Borg" targetType: @"Borg"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockSquadronUpgrade class] entityName: @"Squadron" targetType: @"Squadron"];
    [self loadItems: xmlData[@"Upgrades"] itemClass: [DockResourceUpgrade class] entityName: @"ResourceUpgrade" targetType: @"Resource"];
    [self loadItems: xmlData[@"Resources"] itemClass: [DockResource class] entityName: @"Resource" targetType: @"Resource"];
    [self loadItems: xmlData[@"Flagships"] itemClass: [DockFlagship class] entityName: @"Flagship" targetType: nil];
    [self loadItems: xmlData[@"FleetCaptains"] itemClass: [DockFleetCaptain class] entityName: @"FleetCaptain" targetType: kFleetCaptainUpgradeType];
    [self loadItems: xmlData[@"Officers"] itemClass: [DockOfficer class] entityName: @"Officer" targetType: kOfficerUpgradeType];
    [self loadItems: xmlData[@"ReferenceItems"] itemClass: [DockReference class] entityName: @"Reference" targetType: nil];

    return [self.managedObjectContext save: error];
}

-(NSString*)getVersion:(NSString*)pathToDataFile
{
    NSString* version = nil;
    _versionOnly = YES;
    if ([self loadDataFile: pathToDataFile force: NO error: nil]) {
        version = _dataVersion;
    }
    return version;
}

@end
