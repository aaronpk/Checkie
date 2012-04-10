#import "CITableViewController.h"
@class CIVenue;

@interface CIVenuesTableViewController : CITableViewController <UITextFieldDelegate, UIAlertViewDelegate> {
	UITextField *_searchField;
}

@property (nonatomic, retain) NSMutableArray *cellObjects;

- (void)refresh;
- (void)refreshWithSearch:(BOOL)search;
- (void)checkInAtVenue:(CIVenue *)venue;

- (void)updateCellObjects;

- (void)settings;

- (void)login:(NSNotification *)notification;

@end
