#import <UIKit/UIKit.h>

#import "CIFoursquareEngine.h"
#import "CIVenue.h"

@interface CICheckInCell : UITableViewCell {
	CIVenue *_venue;
	
	UIActivityIndicatorView *_activityIndicator;
	UIImageView *_check;
	
	UILabel *_pointsLabel;
}

@property (nonatomic, retain) CIVenue *venue;

+ (CGFloat)height;

@end
