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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundImage:[UIImage imageNamed:@"flat_rate_bubble_unselected"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"flat_rate_bubble_selected"] forState:UIControlStateSelected];
        [self setAdjustsImageWhenHighlighted:false];
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
