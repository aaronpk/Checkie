#import <UIKit/UIKit.h>
#import "CIVenue.h"

@interface CIVenueCell : UITableViewCell {
	CIVenue *_venue;
	
	UIImageView *_bubbleArrowView;
}

@property (nonatomic, retain) CIVenue *venue;

+ (CGFloat)heightWithVenue:(CIVenue *)venue;
- (void)update;

@end
