#import "DockSquadImporter.h"

#import "DockSquad+Addons.h"
#import "ISO8601DateFormatter.h"

@interface DockSquadImporter () {
    NSString* _path;
    NSMutableArray* _newData;
    NSMutableArray* _existingData;
    NSDictionary* _squadsByUUID;
    NSManagedObjectContext* _context;
    BOOL _importOK;
}
@end

@implementation DockSquadImporter

-(id)initWithPath:(NSString*)path context:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self != nil) {
        _path = path;
        _context = context;
        _newData = [[NSMutableArray alloc] init];
        _existingData = [[NSMutableArray alloc] init];
    }
    return self;
}

NSString* createAmountTermFormat(NSString* format1, NSString* format2, NSInteger count, NSString* actionVerb)
{
    if (count > 0) {
        if (count == 1) {
            return [NSString stringWithFormat: format1, actionVerb];
        }
        return [NSString stringWithFormat: format2, actionVerb, (int)count];
    }
    return nil;
}

NSString* createAmountTerm(NSInteger count, NSString* actionVerb)
{
    return createAmountTermFormat(@"%@ one squad", @"%@ %d squads", count, actionVerb);
}

-(void)examineImport:(NSWindow*)window
{
    NSData* data = [NSData dataWithContentsOfFile: _path];
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
    if (json == nil) {
        NSAlert* alert = [NSAlert alertWithError: error];
        [alert beginSheetModalForWindow: window completionHandler: nil];
        return;
    }
    
    if (![json isKindOfClass: [NSArray class]]) {
        json = [NSArray arrayWithObject: json];
    }
    
    NSArray* currentSquads = [DockSquad allSquads: _context];
    NSMutableDictionary* squadsByUUIDMut = [NSMutableDictionary dictionaryWithCapacity: currentSquads.count];
    for (DockSquad* squad in currentSquads) {
        squadsByUUIDMut[squad.uuid] = squad;
    }
    
    _squadsByUUID = [NSDictionary dictionaryWithDictionary: squadsByUUIDMut];
    
    for (NSDictionary* squadData in json) {
        NSString* uuid = squadData[@"uuid"];
        DockSquad* existing = _squadsByUUID[uuid];
        if (existing != nil) {
            NSDate* modified = existing.modified;
            NSString* modifiedInString = squadData[@"modified"];
            NSDate* modifiedIn = [[[ISO8601DateFormatter alloc] init] dateFromString: modifiedInString];
            if ([modifiedIn compare: modified] == NSOrderedDescending) {
                [_existingData addObject: squadData];
            }
        } else {
            [_newData addObject: squadData];
        }
    }
    
    NSMutableArray* terms = [NSMutableArray arrayWithCapacity: 0];
    NSString* amountTerm = createAmountTerm(_newData.count, @"create");
    if (amountTerm) {
        [terms addObject: amountTerm];
    }
    
    amountTerm = createAmountTerm(_existingData.count, @"update");
    if (amountTerm) {
        [terms addObject: amountTerm];
    }
    
    
    if (terms.count > 0) {
        NSString* importWarning = [NSString stringWithFormat: @"This import will %@.", [terms componentsJoinedByString: @" and "]];
        NSAlert* airbag = [[NSAlert alloc] init];
        airbag.messageText = importWarning;
        [airbag addButtonWithTitle: @"Import"];
        [airbag addButtonWithTitle: @"Cancel"];
        id handler = ^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {
                [self performImport];
            }
        };
        [airbag beginSheetModalForWindow: window completionHandler: handler];
    }
}

-(BOOL)importOK
{
    return _importOK;
}

-(void)performImport
{
    for (NSDictionary* squadData in _newData) {
        [DockSquad importOneSquad: squadData context: _context];
    }
    
    for (NSDictionary* squadData in _existingData) {
        NSString* uuid = squadData[@"uuid"];
        DockSquad* squad = [_squadsByUUID objectForKey: uuid];
        [squad importIntoSquad: squadData replaceUUID: NO];
    }
    
}

@end
