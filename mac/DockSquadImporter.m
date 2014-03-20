#import "DockSquadImporter.h"

#import "DockSquad+Addons.h"
#import "ISO8601DateFormatter.h"

@interface DockSquadImporter () {
    NSString* _path;
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
    }
    return self;
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
    NSMutableDictionary* squadsByUUID = [NSMutableDictionary dictionaryWithCapacity: currentSquads.count];
    for (DockSquad* squad in currentSquads) {
        squadsByUUID[squad.uuid] = squad;
    }
    
    for (NSDictionary* squadData in json) {
        NSString* uuid = squadData[@"uuid"];
        DockSquad* existing = squadsByUUID[uuid];
        if (existing != nil) {
            NSLog(@"existing %@", squadData[@"uuid"]);
            NSDate* modified = existing.modified;
            NSString* modifiedInString = squadData[@"modified"];
            NSDate* modifiedIn = [[[ISO8601DateFormatter alloc] init] dateFromString: modifiedInString];
            if ([modifiedIn compare: modified] == NSOrderedDescending) {
                NSLog(@"want to import %@", squadData[@"uuid"]);
            }
        } else {
            NSLog(@"want to import %@", squadData[@"uuid"]);
        }
    }
}

-(BOOL)importOK
{
    return _importOK;
}

-(void)performImport
{
}

@end
