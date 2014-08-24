#import <Foundation/Foundation.h>

@protocol DockFactioned <NSObject>
@property (strong, nonatomic, readonly) NSSet* factions;
@property (strong, nonatomic, readonly) NSString* highestFaction;
@property (strong, nonatomic, readonly) NSArray* factionsSortedByInitiative;
@end
