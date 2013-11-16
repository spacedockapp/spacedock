#import "DockDetailViewController.h"

#import "DockUtils.h"

@interface DockDetailViewController ()
@property (nonatomic, assign) CGFloat labelWidth;
@property (nonatomic, strong) NSArray* attributeNames;
@property (nonatomic, strong) NSArray* attributeTitles;
@end

@implementation DockDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self recalculateWidth];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self recalculateWidth];
}

-(void)recalculateWidth
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"ability"];
    _labelWidth = self.tableView.bounds.size.width - cell.textLabel.bounds.size.width;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"didRotateFromInterfaceOrientation");
    [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
    [self recalculateWidth];
    [self.tableView reloadData];
}

-(NSArray*)attributeNamesToDisplay
{
    return [[[_target entity] attributesByName] allKeys];
}

-(void)setupAttributes
{
    _attributeNames = [self attributeNamesToDisplay];
    NSMutableArray* attributeTitles = [NSMutableArray arrayWithCapacity: _attributeNames.count];
    for (NSString* name in _attributeNames) {
        NSString* s = [name capitalizedString];
        [attributeTitles addObject: s];
    }
    _attributeTitles = [NSArray arrayWithArray: attributeTitles];
}

-(void)setTarget:(NSManagedObject*)target
{
    _target = target;
    [self setupAttributes];
    [self.tableView reloadData];
}

-(NSString*)attributeForRow:(NSInteger)row
{
    NSString* attributeName = _attributeNames[row];
    return [NSString stringWithFormat: @"%@", [_target valueForKey: attributeName]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _attributeTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"default";
    NSInteger lastRowIndex = _attributeTitles.count - 1;
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row == lastRowIndex) {
        cellIdentifier = @"ability";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (row == lastRowIndex) {
        cell.detailTextLabel.numberOfLines = 0;
    }

    cell.detailTextLabel.text = [self attributeForRow: row];
    cell.textLabel.text = _attributeTitles[row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastRowIndex = _attributeTitles.count - 1;
    NSInteger row = [indexPath indexAtPosition: 1];
    if (row == lastRowIndex) {
        NSString *str = [self attributeForRow: row];
        if (str.length > 0) {
            CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(_labelWidth-40, 999) lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat rowHeight = size.height+20;
            return rowHeight;
        }
    }
    return tableView.rowHeight;
}
@end
