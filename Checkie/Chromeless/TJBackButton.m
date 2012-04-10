// TJBackButton
// Chromeless
// By Tim Johnsen

#import "TJBackButton.h"

@implementation TJBackButton

#pragma mark -
#pragma mark NSObject

- (id)init {
	if ((self = [super init])) {
		[self setTint:TJTintBlack];
	}
	
	return self;
}

#pragma mark -
#pragma mark UIView

// TODO: Override other init methods

- (id)initWithFrame:(CGRect)frame {
	CGSize size = [[UIImage imageNamed:@"back"] size];
	if ((self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height)])) {
		[self setTint:TJTintBlack];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	CGSize size = [[UIImage imageNamed:@"back"] size];
	[super setFrame:CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height)];
}

- (void)setBounds:(CGRect)bounds {
	CGSize size = [[UIImage imageNamed:@"back"] size];
	[super setBounds:CGRectMake(0.0f, 0.0f, size.width, size.height)];
}

#pragma mark -
#pragma mark TJTinting

- (id)initWithTint:(TJTint)tint {
	if ((self = [super init])) {
		[self setTint:tint];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame tint:(TJTint)tint {
	if ((self = [super initWithFrame:frame])) {
		[self setTint:tint];
	}
	
	return self;
}

- (void)setTint:(TJTint)tint {
	[self setTitle:@"  Back" forState:UIControlStateNormal];
	[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0f]];
	[self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[self setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
	[self setAdjustsImageWhenHighlighted:YES];
	
	if (tint == TJTintWhite) {
		[self setBackgroundImage:[UIImage imageNamed:@"backWhite"] forState:UIControlStateNormal];
		
		[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	} else {
		[self setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
}

- (TJTint)tint {
	return ([self titleColorForState:UIControlStateNormal] == [UIColor whiteColor]) ? TJTintBlack : TJTintWhite;
}

@end
