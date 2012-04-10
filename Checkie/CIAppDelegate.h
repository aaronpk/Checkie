#import <UIKit/UIKit.h>
#import "CIVenuesTableViewController.h"

@interface CIAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

- (CIVenuesTableViewController *)venuesViewController;

- (void)userDidLogOut:(NSNotification *)notification;
- (void)userDidLogIn:(NSNotification *)notification;

@end
