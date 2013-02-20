//
//  ErrorPage.m
//  Parkify
//
//  Created by Me on 1/24/13.
//
//

#import "TestPage.h"

@implementation TestPage

@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code  
    }
    
    int r = arc4random() % 80;
    
    UIColor* color = [UIColor colorWithWhite:r/100.0 alpha:0.5];
    
    self.label = [[UILabel alloc] initWithFrame:frame];
    self.label.backgroundColor = color;
    self.label.text = @"TEST";
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.label];
    
    return self;
}

- (void)moreToLeft:(BOOL)isMore {
   
}
- (void)moreToRight:(BOOL)isMore {
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
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
