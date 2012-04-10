#import "CILogInViewController.h"
#import "UIViewController+Loading.h"
#import "CIFoursquareEngine.h"
#import "JSONKit.h"

@implementation CILogInViewController

- (id)init {
	if (self = [super initWithNibName:@"CILogInViewController" bundle:[NSBundle mainBundle]]) {
	}
	
	return self;
}

- (void)viewDidUnload {
	[webView stopLoading];
	[webView setDelegate:nil];
	webView = nil;
	activityIndicator = nil;
    [super viewDidUnload];
}

- (void)dealloc {
	[webView release];
	[activityIndicator release];
	[super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	[self goToSignInPage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)goToSignInPage {
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@", [CIFoursquareEngine clientID], @"http://www.google.com"]]]];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityIndicator stopAnimating];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *url =[[request URL] absoluteString];
	if ([url rangeOfString:@"code="].length != 0) {
		
		NSHTTPCookie *cookie;
		NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		for (cookie in [storage cookies]) {
			if ([[cookie domain] isEqualToString:@"foursquare.com"]) {
				[storage deleteCookie:cookie];
			}
		}
		
		NSArray *array = [url componentsSeparatedByString:@"="];
		
		[self startLoading:YES withTint:TJTintWhite];
		
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://foursquare.com/oauth2/access_token?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@", [CIFoursquareEngine clientID], [CIFoursquareEngine clientSecret], [CIFoursquareEngine callbackURL], [array objectAtIndex:1]]]];
			
			// TODO: Error checking...
			
			NSDictionary *result = [[JSONDecoder decoder] objectWithData:data];
			
			if ([result valueForKey:@"access_token"]) {
				[[NSUserDefaults standardUserDefaults] setObject:[result valueForKey:@"access_token"] forKey:@"token"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					[self succeed];
				});
			} else {
				dispatch_sync(dispatch_get_main_queue(), ^{
					[self fail];
				});
			}
		});
		
		return NO;
		
	} else {
		if ([url rangeOfString:@"error="].length != 0) {
			NSArray *array = [url componentsSeparatedByString:@"="];
			NSString *error = [array objectAtIndex:1];
			NSLog(@"%@", error);
			
			return NO;
		}
	} 
	return YES;
}

#pragma mark - Finishing

- (void)succeed {
	[self stopLoadingAnimated:YES];
	[activityIndicator stopAnimating];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"login" object:nil]];
}

- (void)fail {
	[[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to log into foursquare at this time" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
	[self stopLoadingAnimated:YES];
	[activityIndicator stopAnimating];
	[[self navigationController] popViewControllerAnimated:YES];	
}

@end
