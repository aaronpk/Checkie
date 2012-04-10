#import <UIKit/UIKit.h>

@interface CITableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *_tableView;
	
	NSArray *_dataSource;
}

@property (nonatomic, retain) UITableView *tableView;

- (id)objectForIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForObject:(id)object;
- (CGFloat)heightForObject:(id)object;

@end
