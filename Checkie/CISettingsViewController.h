#import <UIKit/UIKit.h>

@interface CISettingsViewController : UIViewController <UIAlertViewDelegate> {
	IBOutlet UIImageView *icon;
}

- (IBAction)back;
- (IBAction)logOut;
- (IBAction)feedback;

@end
