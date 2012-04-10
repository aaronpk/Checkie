@interface CILogInViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

- (IBAction)goToSignInPage;

- (void)succeed;
- (void)fail;

@end
