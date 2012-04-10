//
//  UITableView + PullToRefresh.m
//  Spartan
//
//  Created by Tim Johnsen on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITableView + PullToRefresh.h"

#define HEADER_HEIGHT ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 60 : 80)

#define PULL_TO_REFRESH_TAG 500
#define PULL_TO_REFRESH_IMAGE_TAG 501
#define PULL_TO_REFRESH_LABEL_TAG 502
#define PULL_TO_REFRESH_INDICATOR_TAG 503

#define PULL_TO_REFRESH_TEXT	@"Pull to Refresh"
#define RELEASE_TO_REFRESH_TEXT @"Release to Refresh"
#define REFRESHING_TEXT			@"Refreshing"

@protocol PullToRefresh

- (void)refresh;

@end

@implementation UITableView (PullToRefresh)

BOOL arrowOrientation;

-(void)setupPullToRefresh{
	[self setupPullToRefreshWithTint:TJPullToRefreshTintDark];
}

-(void)setupPullToRefreshWithTint:(TJPullToRefreshTint)tint{
	UIView *headerView = nil;
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0, - HEADER_HEIGHT, self.bounds.size.width, HEADER_HEIGHT)];
		[headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	}
	else{
		headerView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - 160, - HEADER_HEIGHT, 320, HEADER_HEIGHT)];
		[headerView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
	}
	
	[headerView setTag:PULL_TO_REFRESH_TAG];
	[headerView setBackgroundColor:[UIColor clearColor]];
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:[headerView bounds]];
	[headerLabel setBackgroundColor:[UIColor clearColor]];
	[headerLabel setTextAlignment:UITextAlignmentCenter];
	[headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[headerLabel setText:PULL_TO_REFRESH_TEXT];
	if(tint == TJPullToRefreshTintDark)
		[headerLabel setTextColor:[UIColor blackColor]];
	else
		[headerLabel setTextColor:[UIColor whiteColor]];
	[headerLabel setTag:PULL_TO_REFRESH_LABEL_TAG];
	[headerLabel setFont:[UIFont boldSystemFontOfSize:[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 14 : 20]];
	[headerView addSubview:[headerLabel autorelease]];
	[self addSubview:[headerView autorelease]];
	
	UIActivityIndicatorView *indicator;
	if(tint == TJPullToRefreshTintDark)
		indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	else
		indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[indicator setCenter:CGPointMake(HEADER_HEIGHT / 2, HEADER_HEIGHT / 2)];
	[indicator setTag:PULL_TO_REFRESH_INDICATOR_TAG];
	[indicator startAnimating];
	[indicator setHidesWhenStopped:NO];
	[headerView addSubview:[indicator autorelease]];
	[indicator setHidden:YES];
	
	UIImageView *image;
	if(tint == TJPullToRefreshTintDark)
		image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pullToRefresh.png"]];
	else
		image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pullToRefreshLight.png"]];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setFrame:CGRectMake(0, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
	[image setContentMode:UIViewContentModeCenter];
	[image setTag:PULL_TO_REFRESH_IMAGE_TAG];
	[image setAlpha:.5];
	[headerView addSubview:[image autorelease]];
}

-(void)removePullToRefresh{
	[[self viewWithTag:PULL_TO_REFRESH_TAG] removeFromSuperview];
}

-(BOOL)hasPullToRefresh{
	return [self viewWithTag:PULL_TO_REFRESH_TAG] != nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	if(scrollView.contentOffset.y < 0 && ![self isLoading]){
		
		if(scrollView.contentOffset.y < - HEADER_HEIGHT){
			[(UILabel *)[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_LABEL_TAG] setText:RELEASE_TO_REFRESH_TEXT];
			
			if(!arrowOrientation){
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationBeginsFromCurrentState:YES];
				[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setTransform:CGAffineTransformMakeRotation(-M_PI)];
				[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setAlpha:1];
				[UIView commitAnimations];
				arrowOrientation = YES;
			}
		}
		else{
			[(UILabel *)[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_LABEL_TAG] setText:PULL_TO_REFRESH_TEXT];
			
			if(arrowOrientation){
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationBeginsFromCurrentState:YES];
				[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setTransform:CGAffineTransformMakeRotation(0)];
				[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setAlpha:.5];
				[UIView commitAnimations];
				arrowOrientation = NO;
			}
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if(scrollView.contentOffset.y < - HEADER_HEIGHT && ![self isLoading] && [self viewWithTag:PULL_TO_REFRESH_TAG] != nil)
		[self startLoading];
}

-(void)startLoading{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	
	[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setHidden:YES];
	[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_INDICATOR_TAG] setHidden:NO];
	
	[self setContentInset:UIEdgeInsetsMake(HEADER_HEIGHT, 0, -736, 0)];
	
	[(UILabel *)[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_LABEL_TAG] setText:REFRESHING_TEXT];
	
	[UIView commitAnimations];
	
	if([[self delegate] respondsToSelector:@selector(refresh)])
		[(id<PullToRefresh>)[self delegate] refresh];
}

-(void)stopLoading{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
		
	[self setContentInset:UIEdgeInsetsMake(0, 0, -736, 0)];
//	[self isLoading] = NO;
	
	[(UILabel *)[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_LABEL_TAG] setText:PULL_TO_REFRESH_TEXT];
	[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setTransform:CGAffineTransformMakeRotation(0)];
	[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setAlpha:.5];
	
	[UIView commitAnimations];
	
	[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(finishLoading) userInfo:nil repeats:NO];
}

-(BOOL)isLoading{
	return [[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] isHidden];
}

//-(void)startLoading{
//	[[self viewWithTag:PULL_TO_REFRESH_TAG] setHidden:YES];
//	
//	if([[self delegate] respondsToSelector:@selector(refresh)])
//		[(id<PullToRefresh>)[self delegate] refresh];
//}
//
//-(void)stopLoading{
//	[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setTransform:CGAffineTransformIdentity];
//	[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setAlpha:.5];
//	[[self viewWithTag:PULL_TO_REFRESH_TAG] setHidden:NO];
//}

-(void)finishLoading{
	[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_IMAGE_TAG] setHidden:NO];
	[[[self viewWithTag:PULL_TO_REFRESH_TAG] viewWithTag:PULL_TO_REFRESH_INDICATOR_TAG] setHidden:YES];
	[self scrollViewDidScroll:self];
}

-(void)refresh{
}

@end
