//
//  WaitingMask.m
//  Parkify2
//
//  Created by Me on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaitingMask.h"


@implementation WaitingMask

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView* mask = [[UIView alloc] initWithFrame:frame];
        
        mask.backgroundColor = [UIColor colorWithHue:0 saturation:0.0 brightness:0.0 alpha:0.9];
        
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        
        CGRect indicatorFrame = activityIndicator.frame;
        indicatorFrame.origin.x = (mask.frame.size.width-indicatorFrame.size.width)/2;
        indicatorFrame.origin.y = (mask.frame.size.height-indicatorFrame.size.height)/2;
        activityIndicator.frame = indicatorFrame;
        
        
        [self addSubview:mask];
        [mask addSubview:activityIndicator];
        
        self.alpha = 0;
        [activityIndicator startAnimating];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        }];
        
    }
    return self;
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
