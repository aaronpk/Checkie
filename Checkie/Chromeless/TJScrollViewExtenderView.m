// TJScrollViewExtenderView
// Chromeless
// By Tim Johnsen

#import "TJScrollViewExtenderView.h"

@implementation TJScrollViewExtenderView

@synthesize scrollView;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	self.scrollView = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (self.scrollView) {
		return self.scrollView;
	}
	
	return [super hitTest:point withEvent:event];
}

@end
