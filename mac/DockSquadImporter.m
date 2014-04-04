#import "DockSquadImporter.h"

#import "DockSquad+Addons.h"
#import "ISO8601DateFormatter.h"

@interface DockSquadImporter ()
@end

@implementation DockSquadImporter

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


-(id)initWithPath:(NSString*)path context:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self != nil) {
        _path = path;
        _context = context;
        _notExistingData = [[NSMutableArray alloc] init];
        _existingData = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)importOK
{
    return _importOK;
}

-(void)performImport
{
    for (NSDictionary* squadData in _notExistingData) {
        [DockSquad importOneSquad: squadData replaceUUID: NO context: _context];
    }
    
    for (NSDictionary* squadData in _existingData) {
        NSString* uuid = squadData[@"uuid"];
        DockSquad* squad = [_squadsByUUID objectForKey: uuid];
        [squad importIntoSquad: squadData replaceUUID: NO];
    }
    
}

- (void)announceError:(NSError *)error window:(id)window
{
}

- (void)showAirbag:(NSString *)importWarning window:(id)window
{
}

-(void)examineImport:(id)window
{
    NSData* data = [NSData dataWithContentsOfFile: self.path];
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
    if (json == nil) {
        [self announceError:error window:window];
        return;
    }
    
    if (![json isKindOfClass: [NSArray class]]) {
        json = [NSArray arrayWithObject: json];
    }
    
    NSArray* currentSquads = [DockSquad allSquads: self.context];
    NSMutableDictionary* squadsByUUIDMut = [NSMutableDictionary dictionaryWithCapacity: currentSquads.count];
    for (DockSquad* squad in currentSquads) {
        squadsByUUIDMut[squad.uuid] = squad;
    }
    
    self.squadsByUUID = [NSDictionary dictionaryWithDictionary: squadsByUUIDMut];
    
    for (NSDictionary* squadData in json) {
        NSString* uuid = squadData[@"uuid"];
        DockSquad* existing = self.squadsByUUID[uuid];
        if (existing != nil) {
            NSDate* modified = existing.modified;
            NSString* modifiedInString = squadData[@"modified"];
            NSDate* modifiedIn = [[[ISO8601DateFormatter alloc] init] dateFromString: modifiedInString];
            if ([modifiedIn compare: modified] == NSOrderedDescending) {
                [self.existingData addObject: squadData];
            }
        } else {
            [self.notExistingData addObject: squadData];
        }
    }
    
    NSMutableArray* terms = [NSMutableArray arrayWithCapacity: 0];
    NSString* amountTerm = createAmountTerm(self.notExistingData.count, @"create");
    if (amountTerm) {
        [terms addObject: amountTerm];
    }
    
    amountTerm = createAmountTerm(self.existingData.count, @"update");
    if (amountTerm) {
        [terms addObject: amountTerm];
    }
    
    
    if (terms.count > 0) {
        NSString* importWarning = [NSString stringWithFormat: @"This import will %@.", [terms componentsJoinedByString: @" and "]];
        [self showAirbag:importWarning window:window];
    }
}

@end
