// TJSwitch
// Chromeless
// By Tim Johnsen

#import "TJSwitch.h"

#define INSET 2.0f

@interface TJSwitch ()

- (void)_tap;

@end

@implementation TJSwitch

#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame {
	if (self = [self initWithFrame:frame tint:TJTintBlack]) {
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:CGRectMake(frame.origin.x, frame.origin.y, 94.0f, 27.0f)];
	
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:CGRectMake(0.0f, 0.0f, 94.0f, 27.0f)];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *hit = [super hitTest:point withEvent:event];
	
	if ([hit isDescendantOfView:self]) {
		return _scrollView;
	}
	
	return hit;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	_cachedState = [self isOn];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		if (_cachedState != [self isOn]) {
			[self sendActionsForControlEvents:UIControlEventValueChanged];
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (_cachedState != [self isOn]) {
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

#pragma mark -
#pragma mark UISwitch Emulation

- (BOOL)isOn {
	return _scrollView.contentOffset.x == 0.0f;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
	if (on != [self isOn]) {
		[self toggle:animated];
	}
}

#pragma mark -
#pragma mark TJTinting

- (id)initWithTint:(TJTint)tint {
	if ((self = [self initWithFrame:CGRectZero tint:tint])) {
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame tint:(TJTint)tint {
    self = [super initWithFrame:frame];
    if (self) {
		[super setBounds:CGRectMake(0.0f, 0.0f, 94.0f, 27.0f)];
		
		_inside = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, INSET, INSET)];
		[_inside setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[self addSubview:_inside];
		[_inside release];
		
		UILabel *offLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2.0f, 0.0f, self.bounds.size.width / 2.0f, self.bounds.size.height)];
		[offLabel setText:@"OFF"];
		[offLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
		[offLabel setBackgroundColor:[UIColor clearColor]];
		[offLabel setTextColor:[UIColor lightGrayColor]];
		[offLabel setTextAlignment:UITextAlignmentCenter];
		[self addSubview:offLabel];
		[offLabel release];
		
		_onLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width / 2.0f, self.bounds.size.height)];
		[_onLabel setText:@"ON"];
		[_onLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
		[_onLabel setBackgroundColor:[UIColor clearColor]];
		[_onLabel setTextAlignment:UITextAlignmentCenter];
		[self addSubview:_onLabel];
		[_onLabel release];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2.0f, 0.0f, self.bounds.size.width / 2.0f, self.bounds.size.height)];
		[_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_scrollView setBackgroundColor:[UIColor clearColor]];
		[_scrollView setShowsVerticalScrollIndicator:NO];
		[_scrollView setShowsHorizontalScrollIndicator:NO];
		[_scrollView setContentSize:CGSizeMake(2.0f * _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
		[_scrollView setPagingEnabled:YES];
		[_scrollView setBounces:NO];
		[_scrollView setClipsToBounds:NO];
		[_scrollView setDelegate:self];
		[self addSubview:_scrollView];
		
		_nub = [[UIView alloc] initWithFrame:CGRectInset(CGRectMake(0.0f, 0.0f, _scrollView.bounds.size.width, _scrollView.bounds.size.height), INSET * 2.0f, INSET * 2.0f)];
		[_nub setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_scrollView addSubview:_nub];
		[_nub release];
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tap)];
		[self addGestureRecognizer:tap];
		[tap release];
		
		[self setTint:tint];
		[self setOn:NO animated:NO];
    }
    return self;
}

- (void)setTint:(TJTint)tint {
	UIColor *lightColor = (tint == TJTintWhite) ? [UIColor whiteColor] : [UIColor blackColor];
	UIColor *darkColor = (tint == TJTintWhite) ? [UIColor blackColor] : [UIColor whiteColor];
	
	[self setBackgroundColor:lightColor];
	[_inside setBackgroundColor:darkColor];
	[_onLabel setTextColor:lightColor];
	[_nub setBackgroundColor:lightColor];
}

- (TJTint)tint {
	return ([self backgroundColor] == [UIColor whiteColor]) ? TJTintBlack : TJTintWhite;
}

#pragma mark -
#pragma mark Custom

- (void)toggle {
	[self toggle:YES];
}

- (void)toggle:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	if (_scrollView.contentOffset.x == 0.0f) {
		[_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width, 0.0f)];
	} else {
		[_scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
	}
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Private

- (void)_tap {
	[self toggle:YES];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
