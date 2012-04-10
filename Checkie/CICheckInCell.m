#import "CICheckInCell.h"

@implementation CICheckInCell

@synthesize venue = _venue;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[_activityIndicator release];
	[_check release];
	[_venue release];
	[_pointsLabel release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		[[self contentView] setBackgroundColor:[UIColor blackColor]];
		[[self textLabel] setBackgroundColor:[UIColor blackColor]];
		[[self textLabel] setTextColor:[UIColor whiteColor]];
		[self setIndentationLevel:1];
		[self setIndentationWidth:38.0f];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[_activityIndicator setFrame:CGRectMake(0.0f, 0.0f, [CICheckInCell height], [CICheckInCell height])];
		[_activityIndicator setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
		[_activityIndicator startAnimating];
		[_activityIndicator setHidesWhenStopped:NO];
		[self addSubview:_activityIndicator];
		
		_check = [[UIImageView alloc] init];
		[_check setFrame:CGRectMake(0.0f, 0.0f, [CICheckInCell height], [CICheckInCell height])];
		[_check setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
		[self addSubview:_check];
		
		_pointsLabel = [[UILabel alloc] init];
		[_pointsLabel setBackgroundColor:[UIColor clearColor]];
		[_pointsLabel setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
		[_pointsLabel setTextAlignment:UITextAlignmentRight];
		[_pointsLabel setBounds:CGRectMake(0.0, 0.0, 64.0, 44.0)];
		[_pointsLabel setFont:[UIFont systemFontOfSize:18.0]];
		[_pointsLabel setCenter:CGPointMake(self.bounds.size.width - 12.0 - _pointsLabel.bounds.size.width / 2.0, self.bounds.size.height / 2.0)];
		[self addSubview:_pointsLabel];
	}
	
	return self;
}

#pragma mark -
#pragma mark Getters and Setters

- (void)setVenue:(CIVenue *)venue {
	[_venue autorelease];
	_venue = [venue retain];
	
	if ([[CIFoursquareEngine sharedEngine] isCurrentlyCheckedInAtVenue:self.venue]) {
		_activityIndicator.hidden = YES;
		_check.hidden = NO;
		_check.image = [UIImage imageNamed:@"check"];
		[[self textLabel] setText:@"Checked In!"];
		int points = [[CIFoursquareEngine sharedEngine] checkedInPoints];
		if (points) {
			[_pointsLabel setText:[NSString stringWithFormat:@"+%d", points]];
		} else {
			[_pointsLabel setText:nil];
		}
	} else if ([[CIFoursquareEngine sharedEngine] isCheckingInAtVenue:self.venue]) {
		_activityIndicator.hidden = NO;
		_check.hidden = YES;
		[[self textLabel] setText:@"Checking In..."];
		[_pointsLabel setText:nil];
	} else {
		_activityIndicator.hidden = YES;
		_check.hidden = NO;
		_check.image = [UIImage imageNamed:@"x"];
		[[self textLabel] setText:@"Failed to Check In"];
		[_pointsLabel setText:nil];
	}
}

#pragma mark -
#pragma mark Sizing

+ (CGFloat)height {
	return 44.0f;
}

@end
