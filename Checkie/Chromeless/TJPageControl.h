// TJPageControl
// Chromeless
// By Tim Johnsen

typedef enum{
	TJPageControlStyleEmptyIndicators,
	TJPageControlStyleShadedIndicators
} TJPageControlStyle;

typedef enum{
	TJPageControlTypeCircle,
	TJPageControlTypeSquare
} TJPageControlType;

typedef enum{
	TJPageControlAlignmentCenter,
	TJPageControlAlignmentLeftTop,
	TJPageControlAlignmentRightBottom
} TJPageControlAlignment;


@interface TJPageControl : UIView {
	int _numberOfPages;
	int _currentPage;
	id _delegate;
	
	CGFloat _indicatorSize;
	CGFloat _indicatorSpacing;
	UIColor *_baseColor;
	UIColor *_selectedColor;
	TJPageControlStyle _style;
	TJPageControlType _type;
	TJPageControlAlignment _alignment;
}

@property (nonatomic, assign) int numberOfPages;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) id delegate;

@property (nonatomic, assign) CGFloat indicatorSize;
@property (nonatomic, assign) CGFloat indicatorSpacing;
@property (nonatomic, retain) UIColor *baseColor;
@property (nonatomic, retain) UIColor *selectedColor;
@property (nonatomic, assign) TJPageControlStyle style;
@property (nonatomic, assign) TJPageControlType type;
@property (nonatomic, assign) TJPageControlAlignment alignment;

@end
