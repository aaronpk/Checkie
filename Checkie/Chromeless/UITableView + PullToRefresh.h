//
//  UITableView + PullToRefresh.h
//  Spartan
//
//  Created by Tim Johnsen on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
	TJPullToRefreshTintLight,
	TJPullToRefreshTintDark
} TJPullToRefreshTint;


@interface UITableView (PullToRefresh) <UIScrollViewDelegate>

-(void)setupPullToRefresh;
-(void)setupPullToRefreshWithTint:(TJPullToRefreshTint)tint;
-(void)removePullToRefresh;

-(BOOL)hasPullToRefresh;

-(BOOL)isLoading;

-(void)startLoading;
-(void)stopLoading;

-(void)refresh;

@end