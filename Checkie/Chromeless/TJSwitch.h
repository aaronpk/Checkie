// TJSwitch
// Chromeless
// By Tim Johnsen

#import <UIKit/UIKit.h>
#import "TJTinting.h"

@interface TJSwitch : UIControl <UIScrollViewDelegate, TJTinting> {
	UIScrollView *_scrollView;
	UIView *_nub;
	UIView *_inside;
	UILabel *_onLabel;
	BOOL _cachedState;
}

- (BOOL)isOn;
- (void)setOn:(BOOL)on animated:(BOOL)animated;

- (void)toggle;
- (void)toggle:(BOOL)animated;

@end
