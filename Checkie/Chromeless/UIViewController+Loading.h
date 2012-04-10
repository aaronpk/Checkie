// UIViewController+Loading
// Chromeless
// By Tim Johnsen

#import <UIKit/UIKit.h>
#import "TJTinting.h"

@interface UIViewController (Loading) <TJTinting>

- (void)startLoading:(BOOL)animated;
- (void)startLoading:(BOOL)animated withTint:(TJTint)tint;
- (void)stopLoadingAnimated:(BOOL)animated;

@end
