#import "CIAppDelegate.h"
#import "CIFoursquareEngine.h"
#import "CILogInViewController.h"
#import "FlurryAnalytics.h"

void uncaughtExceptionHandler(NSException *exception);
void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
}

@implementation CIAppDelegate

@synthesize window = _window;
@synthesize navigationController;

- (void)dealloc {
	[_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	self.navigationController = [[[UINavigationController alloc] init] autorelease];
	[self.navigationController setNavigationBarHidden:YES];
	
	if ([CIFoursquareEngine isLoggedIn]) {
		[self.navigationController pushViewController:[self venuesViewController] animated:YES];
	} else {
		[self.navigationController pushViewController:[[[CILogInViewController alloc] init] autorelease] animated:YES];
	}
	
	[self.window addSubview:self.navigationController.view];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogIn:) name:@"login" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogOut:) name:@"logout" object:nil];
	
#if !DEBUG
#warning Flurry Key is omitted from the open source version of Checkie
	[FlurryAnalytics startSession:@"[ REDACTED ]"];
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif
	
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[self venuesViewController] refresh];
}

- (CIVenuesTableViewController *)venuesViewController {
	static CIVenuesTableViewController *venues = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		venues = [[CIVenuesTableViewController alloc] init];
	});
	
	return venues;
}

- (void)userDidLogOut:(NSNotification *)notification {
	[self.navigationController setViewControllers:[NSArray arrayWithObject:[[[CILogInViewController alloc] init] autorelease]] animated:YES];
}

- (void)userDidLogIn:(NSNotification *)notification {
	[self.navigationController setViewControllers:[NSArray arrayWithObject:[self venuesViewController]] animated:YES];
}

@end
