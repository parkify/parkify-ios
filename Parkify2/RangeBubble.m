//
//  RangeBubble.m
//  Parkify
//
//  Created by Me on 10/9/12.
//
//


//
//  This class is responsible for displaying the bubbles on the range slider.
//  This includes Displaying the bubble itself as well as the time indicator
//  and the price label.
//

#import "RangeBubble.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>

@interface RangeBubble()

@property (strong, nonatomic) UIView * bubbleBooked;
@property (strong, nonatomic) UIImageView * bubbleFree;
@property (strong, nonatomic) UIImageView * bubbleBackground;


@property double maxLimit;

-(float)xForValue:(float)value;
-(float)valueForX:(float)x;

-(void)updateTrackHighlight;

@end

@implementation RangeBubble

@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize minimumRange = _minimumRange;
@synthesize maxLimit = _maxLimit;
@synthesize selectedMinimumValue = _selectedMinimumValue;
@synthesize selectedMaximumValue = _selectedMaximumValue;


@synthesize bubbleBooked = _bubbleBooked;
@synthesize bubbleFree = _bubbleFree;
@synthesize bubbleBackground = _bubbleBackground;

@synthesize timeFormatter = _timeFormatter;
@synthesize priceFormatter = _priceFormatter;

-(void) setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    self.bubbleBackground.alpha = alpha;
    self.bubbleBooked.alpha = alpha;
    self.bubbleFree.alpha = alpha;
}

-(void) setSelectedMaximumValue:(double)selectedMaximumValue {
    selectedMaximumValue = MIN(MAX(self.minimumValue, selectedMaximumValue), self.maximumValue);
    
    if (_selectedMaximumValue != selectedMaximumValue) {
        _selectedMaximumValue = selectedMaximumValue;
        [self updateTrackHighlight];
    }
}
-(void) setSelectedMinimumValue:(double)selectedMinimumValue {
    selectedMinimumValue = MIN(MAX(self.minimumValue, selectedMinimumValue), self.maximumValue);
    
    if (_selectedMinimumValue != selectedMinimumValue) {
        _selectedMinimumValue = selectedMinimumValue;
        [self updateTrackHighlight];
    }
}

-(Formatter)timeFormatter {
    if(!_timeFormatter) {
        _timeFormatter = ^(double val) {
            return [NSString stringWithFormat:@"%f", floor(val)]; };
    }
    return _timeFormatter;
}

-(Formatter)priceFormatter {
    if(!_priceFormatter) {
        _priceFormatter = ^(double val) {
            return [NSString stringWithFormat:@"%f", floor(val)]; };
    }
    return _priceFormatter;
}

- (RangeBubble*)initWithFrame:(CGRect)frame minVal:(double)minVal maxVal:(double)maxVal minRange:(double)minRange selectedMinVal:(double)selectedMinVal selectedMaxVal:(double)selectedMaxVal withPriceFormatter:(Formatter)priceFormatter withTimeFormatter:(Formatter)timeFormatter {
    
    [self setUserInteractionEnabled:false];
    
    self = [super initWithFrame:frame];
    if (self) {
        
        double w = frame.size.width;
        double h = frame.size.height;
        
        self.minimumValue = minVal;
        self.maximumValue = maxVal;
        self.minimumRange = minRange;
        self.priceFormatter = priceFormatter;
        self.timeFormatter = timeFormatter;
        
        self.selectedMinimumValue = selectedMinVal;
        self.selectedMaximumValue = selectedMaxVal;
        self.maxLimit = selectedMaxVal;
        
        //track background
        UIImage* imgNone = [UIImage imageWithImage:[UIImage imageNamed:@"slider_dark_background.png"] scaledToSize:CGSizeMake(w, h)];
        self.bubbleBackground = [[UIImageView alloc] initWithImage:imgNone];
        self.bubbleBackground.contentMode = UIViewContentModeLeft;
        
        
        self.bubbleBackground.alpha = self.alpha;
        
        //track free
        UIImage* imgWhite = [UIImage imageWithImage:[UIImage imageNamed:@"unselected_bubble.png"] scaledToSize:CGSizeMake(w, h)];
        self.bubbleFree = [[UIImageView alloc] initWithImage:imgWhite];
        self.bubbleFree.contentMode = UIViewContentModeLeft;
        self.bubbleFree.autoresizingMask = UIViewAutoresizingNone;
        self.bubbleFree.clipsToBounds = true;
        
        
        [self addSubview:self.bubbleFree];
        
        //track booked
        UIImage* imgBlue = [UIImage imageWithImage:[UIImage imageNamed:@"selected_bubble.png"] scaledToSize:CGSizeMake(w, h)];
        UIImageView* bubbleBookedImgView = [[UIImageView alloc] initWithImage:imgBlue];
        
        bubbleBookedImgView.frame = frame;
        bubbleBookedImgView.alpha = self.alpha;
        
        self.bubbleBooked = [[UIView alloc] initWithFrame:frame];
        [self.bubbleBooked addSubview:bubbleBookedImgView];
        [self.bubbleBooked setAutoresizesSubviews:false];
        [self.bubbleBooked setClipsToBounds:true];
        
        [self addSubview:self.bubbleBooked];
        
        
        
        
        //Adust everything!
        [self updateTrackHighlight];
    }
    return self;
}

//I suggest you don't use this one.
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame: frame minVal:0 maxVal:1 minRange:0.1 selectedMinVal:0.1 selectedMaxVal:0.9 withPriceFormatter:^NSString *(double val) {
        return @"DEFAULT";
    } withTimeFormatter:^NSString *(double val) {
        return @"DEFAULT";
    }];
}


-(float)xForValue:(float)value {
    float normalizedValue = (value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    float x = (self.frame.size.width) * normalizedValue;
    return x;
}
-(float)valueForX:(float)x {
    return self.minimumValue / (self.frame.size.width) * (self.maximumValue - self.minimumValue);
}

- (void) handleEndTouch {
}

//for now, don't worry about multiple touches.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {}

- (void)updateTrackHighlight{
    
    
    
    float begin = [self xForValue:self.selectedMinimumValue];
    float end = [self xForValue:self.selectedMaximumValue];
    

    
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(begin,0,end-begin ,self.bubbleBooked.frame.size.height);
    maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"maskImage.png"] CGImage];

    
    self.bubbleBooked.layer.mask = maskLayer;
    
    [self.bubbleBackground setNeedsDisplay];
    
   
    
    /*[self.bubbleBooked setContentMode:UIViewContentModeRight];
    self.bubbleBooked.bounds = CGRectMake(begin,
                                          0,
                                          end-begin,
                                          self.bubbleBooked.bounds.size.height);
     */
    //self.bubbleBooked.center = CGPointMake((begin+end)/2.0, self.bubbleBooked.center.y);

}

-(NSString*) description {
    Formatter f = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        return [dateFormatter stringFromDate:time]; };
    
    return [NSString stringWithFormat:@"(minVal:%@,maxVal:%@,minSelVal:%@,maxSelVal:%@)", f(self.minimumValue), f(self.maximumValue), f(self.selectedMinimumValue), f(self.selectedMaximumValue)];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 
 }
 */

@end

