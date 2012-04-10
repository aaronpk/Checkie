#import "CITableViewController.h"

@implementation CITableViewController

@synthesize tableView = _tableView;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[_tableView setDelegate:nil];
	[_tableView setDataSource:nil];
	[_tableView release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	
	self.tableView = [[[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain] autorelease];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorColor = [UIColor blackColor];
	[[self view] addSubview:[self tableView]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 0;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self cellForObject:[self objectForIndexPath:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self heightForObject:[self objectForIndexPath:indexPath]];
}

#pragma mark -
#pragma mark UITableViewDelegate

#pragma mark -
#pragma mark CITableViewController

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (CGFloat)heightForObject:(id)object {
	return 44.0f;
}

- (UITableViewCell *)cellForObject:(id)object {
	return nil;
}

@end
