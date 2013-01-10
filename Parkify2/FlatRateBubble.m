//
//  FlatRateBubble.m
//  Parkify
//
//  Created by Me on 1/3/13.
//
//

#import "FlatRateBubble.h"

#define BUBBLE_WIDTH 45.0
#define BUBBLE_HEIGHT 42.0
#define BUBBLE_PADDING 4

@implementation FlatRateBubble

@synthesize flatRateName = _flatRateName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundImage:[UIImage imageNamed:@"flat_rate_bubble_unselected"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"flat_rate_bubble_selected"] forState:UIControlStateSelected];
        [self setAdjustsImageWhenHighlighted:false];
        
        //self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 3;
        if ([self.titleLabel respondsToSelector:@selector(setMinimumFontSize::)]) {
            [self.titleLabel setMinimumFontSize:8.0];
        } else if ([self.titleLabel respondsToSelector:@selector(setMinimumScaleFactor:)]) {
            [self.titleLabel setMinimumScaleFactor:8.0];
        }
        
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.lineBreakMode = NSLineBreakByClipping;
        
        
    }
    return self;
}

+ (double) width {
    return BUBBLE_WIDTH;
}
+ (double) height {
    return BUBBLE_HEIGHT;
}
+ (double) padding {
    return BUBBLE_PADDING;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
