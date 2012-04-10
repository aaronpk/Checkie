#import "CIVenueCell.h"
#import "CIFoursquareEngine.h"

@implementation CIVenueCell

@synthesize venue = _venue;

#pragma mark -
#pragma mark NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		[[self textLabel] setNumberOfLines:0];
		[[self textLabel] setLineBreakMode:UILineBreakModeWordWrap];
		[[self textLabel] setFont:[UIFont boldSystemFontOfSize:18.0f]];
		
		UIView *backgroundView = [[UIView alloc] init];
		[backgroundView setBackgroundColor:[UIColor blackColor]];
		[self setSelectedBackgroundView:backgroundView];
		[backgroundView release];
		
		_bubbleArrowView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, self.bounds.size.height - 10.0f, 20.0f, 10.0f)];
		[_bubbleArrowView setImage:[UIImage imageNamed:@"bubbleArrow"]];
		[_bubbleArrowView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
		[self addSubview:_bubbleArrowView];
		[_bubbleArrowView setHidden:YES];
	}
	
	return self;
}

- (void)dealloc {
	[_venue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark CIVenueCell

- (void)setVenue:(CIVenue *)venue {
	[_venue autorelease];
	_venue = [venue retain];
	
	[self update];
}

- (void)update {
	[[self textLabel] setText:self.venue.name];
	
	if ([[CIFoursquareEngine sharedEngine] isCheckingInAtVenue:self.venue] || [[CIFoursquareEngine sharedEngine] isCurrentlyCheckedInAtVenue:self.venue]) {
		_bubbleArrowView.hidden = NO;
	} else {
		_bubbleArrowView.hidden = YES;
	}
}

#pragma mark -
#pragma mark Sizing

+ (CGFloat)heightWithVenue:(CIVenue *)venue {
	CGFloat height = [venue.name sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(300.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height + 20;
	
	if (height < 44.0f) {
		return 44.0f;
	}
	
	return height;
}

@end
