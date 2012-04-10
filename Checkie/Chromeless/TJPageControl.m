// TJPageControl
// Chromeless
// By Tim Johnsen

#import "TJPageControl.h"

@implementation TJPageControl

@synthesize currentPage = _currentPage;
@synthesize numberOfPages = _numberOfPages;
@synthesize delegate = _delegate;

@synthesize indicatorSize = _indicatorSize;
@synthesize indicatorSpacing = _indicatorSpacing;
@synthesize baseColor = _baseColor;
@synthesize selectedColor = _selectedColor;
@synthesize style = _style;
@synthesize type = _type;
@synthesize alignment = _alignment;

#pragma mark -
#pragma mark NSObject

- (id)init {
	if (self = [self initWithFrame:CGRectZero]) {
	}
	return self;
}

- (void)dealloc {
	[_baseColor release];
	[_selectedColor release];
	
	_delegate = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor clearColor]];
		self.currentPage = 0;
		self.numberOfPages = 0;
		
		self.indicatorSize = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 4 : 6;
		self.indicatorSpacing = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 10 : 14;
		
		self.baseColor = [UIColor grayColor];
		self.selectedColor = [UIColor grayColor];
		
		self.style = TJPageControlStyleEmptyIndicators;
		self.type = TJPageControlTypeCircle;
		self.alignment = TJPageControlAlignmentCenter;
	}
	
	return self;
}

- (void)setFrame:(CGRect)rect {
	[super setFrame:rect];
	[self setNeedsDisplay];
}

- (void)setNumberOfPages:(int)n {
	_numberOfPages = n;
	[self setNeedsDisplay];
}

- (void)setCurrentPage:(int)n {
	_currentPage = n;
	
	while (self.currentPage >= self.numberOfPages) {
		_currentPage--;
	}
	
	while (self.currentPage < 0) {
		_currentPage++;
	}
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	if (self.numberOfPages > 1) {
		
		float length = self.numberOfPages * self.indicatorSize + self.indicatorSpacing * (self.numberOfPages - 1);
			
		float x = rect.size.width / 2, y = rect.size.height / 2;
		
		if(self.bounds.size.width > self.bounds.size.height){
			y -= self.indicatorSize / 2;
			switch (self.alignment) {
				case TJPageControlAlignmentCenter:
					x -= length / 2;
					break;
				case TJPageControlAlignmentLeftTop:
					x = self.indicatorSpacing;
					break;
				case TJPageControlAlignmentRightBottom:
					x = self.bounds.size.width - length - self.indicatorSpacing;
			}
		} else {
			x -= self.indicatorSize / 2;
			
			switch (self.alignment) {
				case TJPageControlAlignmentCenter:
					y -= length / 2;
					break;
				case TJPageControlAlignmentLeftTop:					
					y = self.indicatorSpacing;
					break;
				case TJPageControlAlignmentRightBottom:
					y = self.bounds.size.height - length - self.indicatorSpacing;
			}
		}
			
		// draw each of the indicators	
		for (int i = 0 ; i < self.numberOfPages ; i++) {
			if (self.style == TJPageControlStyleEmptyIndicators) {
				// draw empty indicators
				if (i == self.currentPage) {
					[self.selectedColor setFill];
					if (self.type == TJPageControlTypeCircle) {
						CGContextFillEllipseInRect(context, CGRectMake(x, y, self.indicatorSize, self.indicatorSize));
					} else {
						CGContextFillRect(context, CGRectMake(x, y, self.indicatorSize, self.indicatorSize));
					}
				}
				[self.baseColor setStroke];
				if (self.type == TJPageControlTypeCircle) {
					CGContextStrokeEllipseInRect(context, CGRectMake(x, y, self.indicatorSize, self.indicatorSize));
				} else {
					CGContextStrokeRect(context, CGRectMake(x, y, self.indicatorSize, self.indicatorSize));
				}
			} else {
				// draw shaded indicators
				if (i == self.currentPage) {
					[self.selectedColor setFill];
				} else {
					[self.baseColor setFill];
				}
				
				if (self.type == TJPageControlTypeCircle) {
					CGContextFillEllipseInRect(context, CGRectMake(x, y, self.indicatorSize, self.indicatorSize));
				} else {
					CGContextFillRect(context, CGRectMake(x, y, self.indicatorSize, self.indicatorSize));
				}
			}
			
			if (self.bounds.size.width > self.bounds.size.height) {
				x += self.indicatorSize + self.indicatorSpacing;
			} else {
				y += self.indicatorSize + self.indicatorSpacing;
			}
		}
	}
}

@end
