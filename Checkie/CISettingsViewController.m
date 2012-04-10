#import "CISettingsViewController.h"
#import "CIFoursquareEngine.h"
#import "MessageUI + TJAdditions.h"

@implementation CISettingsViewController

#pragma mark -
#pragma mark NSObject

- (id)init {
	if ((self = [super initWithNibName:@"CISettingsViewController" bundle:[NSBundle mainBundle]])) {
	}
	
	return self;
}

- (void)dealloc {
	[icon release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	icon.layer.cornerRadius = 12.0f;
	
	UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
	[[self view] addGestureRecognizer:gr];
	[gr release];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[icon release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Log Out"]) {
		[[CIFoursquareEngine sharedEngine] logout];
	}
}

#pragma mark -
#pragma mark Actions

- (IBAction)back {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)logOut {
	[[[[UIAlertView alloc] initWithTitle:@"Log Out?" message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil] autorelease] show];
}

- (IBAction)feedback {
	[MFMailComposeViewController presentFeedbackEmailViewControllerInViewController:self];
}

@end
