// UIViewController+Loading
// Chromeless
// By Tim Johnsen

#import "UIViewController+Loading.h"

#define LOADING_TAG -1
#define LOADING_LABEL_TAG -2
#define LOADING_ACTIVITY_INDICATOR_TAG -3

@implementation UIViewController (Loading)

#pragma mark -
#pragma mark TJTinting

- (void)setTint:(TJTint)tint {
	
	// Setup views
	
	if ([[self view] viewWithTag:LOADING_TAG] == nil) {
		
		id loadingView = [[UIView alloc] initWithFrame:[self view].bounds];
		[loadingView setAlpha:0];
		[loadingView setTag:LOADING_TAG];
		[loadingView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
		[loadingView setUserInteractionEnabled:NO];
		
		UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160, 160)];
		[container setCenter:[(UIView *)loadingView center]];
		[container setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
		[loadingView addSubview:container];
		[container setBackgroundColor:[UIColor clearColor]];
		[container release];
		
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,32,32)];
		[activityIndicator setTag:LOADING_ACTIVITY_INDICATOR_TAG];
		[activityIndicator setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
		[activityIndicator setCenter:CGPointMake(80.0f, 80.0f)];
		[activityIndicator startAnimating];
		[container addSubview:activityIndicator];
		[activityIndicator release];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 160, 80)];
		[label setTag:LOADING_LABEL_TAG];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setText:@"Loading..."];
		[label setClipsToBounds:NO];
		[label setTextAlignment:UITextAlignmentCenter];
		[label setFont:[UIFont boldSystemFontOfSize:[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 18 : 28]];
		[label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
		[container addSubview:label];
		[label release];
		
		[[self view] addSubview:loadingView];
		[loadingView release];
	}
	
	// Set Colors
	
	UIView *loadingView = [[self view] viewWithTag:LOADING_TAG];
	[loadingView setBackgroundColor:tint == TJTintWhite ? [UIColor colorWithRed:1 green:1 blue:1 alpha:.8] : [UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
	[(UILabel *)[[self view] viewWithTag:LOADING_LABEL_TAG] setTextColor:tint == TJTintWhite ? [UIColor grayColor] : [UIColor whiteColor]];
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[loadingView viewWithTag:LOADING_ACTIVITY_INDICATOR_TAG];
	if ([activityIndicator respondsToSelector:@selector(setColor:)]) {
		[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		if (tint == TJTintWhite) {
			[activityIndicator performSelector:@selector(setColor:) withObject:[UIColor grayColor]];
		}
	} else {
		[activityIndicator setActivityIndicatorViewStyle:tint == TJTintWhite ? UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhiteLarge];
	}
}

- (TJTint)tint {
	if ([[self view] viewWithTag:LOADING_TAG]) {
		return ([[[self view] viewWithTag:LOADING_TAG] backgroundColor] == [UIColor whiteColor]) ? TJTintWhite : TJTintBlack;
	}
	
	return TJTintWhite;
}

#pragma mark -
#pragma mark Custom

- (void)startLoading:(BOOL)animated {
	[self startLoading:animated withTint:TJTintWhite];
}

- (void)startLoading:(BOOL)animated withTint:(TJTint)tint {
	
	[self setTint:tint];
	[[self view] bringSubviewToFront:[[self view] viewWithTag:LOADING_TAG]];
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.25];
	}
	
	[[[self view] viewWithTag:LOADING_TAG] setAlpha:1];
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)stopLoadingAnimated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.25];
	}
	
	[[[self view] viewWithTag:LOADING_TAG] setAlpha:0];
	
	if(animated) {
		[UIView commitAnimations];
	}
}

@end