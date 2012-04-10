//
//  CIVenueViewController.m
//  Checkie
//
//  Created by Tim Johnsen on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CIVenueViewController.h"

@implementation CIVenueViewController

@synthesize venue;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	self.venue = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	
	_textView = [[UITextView alloc] initWithFrame:[[self view] bounds]];
	[[self view] addSubview:_textView];
	[_textView release];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	_textView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[self navigationController] setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[self navigationController] setNavigationBarHidden:YES];
}

#pragma mark -
#pragma mark Custom

- (id)initWithVenue:(CIVenue *)aVenue {
	if ((self = [super init])) {
		self.venue = aVenue;
		
		[[CIFoursquareEngine sharedEngine] getVenueWithID:self.venue.uniqueID andCallback:^(CIVenue *loadedVenue){
			dispatch_async(dispatch_get_main_queue(), ^{
				self.venue = loadedVenue;
			});
		}];
	}
	
	return self;
}

@end