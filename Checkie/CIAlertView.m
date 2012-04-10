#import "CIAlertView.h"

@implementation CIAlertView

@synthesize context;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	self.context = nil;
	
	[super dealloc];
}

@end
