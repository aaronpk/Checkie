//
//  CIVenueViewController.h
//  Checkie
//
//  Created by Tim Johnsen on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIFoursquareEngine.h"

@interface CIVenueViewController : UIViewController {
	UITextView *_textView;
}

@property (nonatomic, retain) CIVenue *venue;

- (id)initWithVenue:(CIVenue *)aVenue;

@end
