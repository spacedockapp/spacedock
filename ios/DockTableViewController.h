#import <UIKit/UIKit.h>

@interface DockTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSArray* sections;
@property (nonatomic, strong) NSArray* sectionLists;
@property (nonatomic, strong) NSString* cellIdentifer;
-(void)setupFetch:(NSFetchRequest*)fetchRequest context:(NSManagedObjectContext*)context;
-(id)objectAtIndexPath:(NSIndexPath*)indexPath;
@property (strong, nonatomic) NSArray* includedSets;
@property (strong, nonatomic) NSString* faction;
@property (strong, nonatomic) NSString* searchTerm;
@property (assign, nonatomic) BOOL ignoreSets;
@property (assign, nonatomic) int cost;
-(void)clearFetch;
-(void)performFetch;
-(BOOL)useFactionFilter;
-(BOOL)useCostFilter;
-(NSPredicate *)makePredicateTemplate;
@end
