// TJTinting
// Chromeless
// By Tim Johnsen

typedef enum {
	TJTintBlack,
	TJTintWhite
} TJTint;

#import <Foundation/Foundation.h>

@protocol TJTinting <NSObject>

- (TJTint)tint;
- (void)setTint:(TJTint)tint;

@optional

- (id)initWithTint:(TJTint)tint;
- (id)initWithFrame:(CGRect)frame tint:(TJTint)tint;

@end
