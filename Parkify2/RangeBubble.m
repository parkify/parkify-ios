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
@property (strong, nonatomic) UIImageView * bubbleNewBackground;
@property (strong, nonatomic) UIImageView * vertBar;
@property (strong, nonatomic) UILabel * priceLabel;
@property (strong, nonatomic) UILabel * timeLabel;
@property (strong, nonatomic) UILabel * dateLabel;
@property CGRect mainRect;
@property (strong, nonatomic) UIColor * selectedColor;
@property (strong, nonatomic) UIColor * newselectedColor;
@property (strong, nonatomic) UIColor * unselectedColor;

@property (strong, nonatomic) NSObject<PriceStore>* priceSource;

@property double maxLimit;

-(double)xForValue:(double)value;
-(double)valueForX:(double)x;

-(void)updateTrackHighlight;

@end

@implementation RangeBubble
@synthesize minimumSelectedValue = _minimumSelectedValue;
@synthesize bubbleNewBackground = _bubbleNewBackground;
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

@synthesize mainRect = _mainRect;
@synthesize selectedColor = _selectedColor;
@synthesize unselectedColor = _unselectedColor;
@synthesize newselectedColor = _newselectedColor;

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

- (RangeBubble*)initWithFrame:(CGRect)frame minVal:(double)minVal maxVal:(double)maxVal minRange:(double)minRange selectedMinVal:(double)selectedMinVal selectedMaxVal:(double)selectedMaxVal withPriceFormatter:(Formatter)priceFormatter withTimeFormatter:(Formatter)timeFormatter withPriceSource:(NSObject<PriceStore>*)priceSource withMinimumSelectedValue:(double)minSelVal {
    
    self.priceSource = priceSource;
    
    [self setUserInteractionEnabled:false];
    
    self = [super initWithFrame:frame];
    if (self) {
        
        double w = frame.size.width;
        double h = frame.size.height;
        
        double h_main = w*2;
        
        //calculate mainRect, which will be where the bubble is actually displayed.
        self.mainRect = CGRectMake(0,h-h_main,w,h_main);
        
        self.minimumValue = minVal;
        self.minimumSelectedValue=minSelVal;
        self.maximumValue = maxVal;
        self.minimumRange = minRange;
        self.priceFormatter = priceFormatter;
        self.timeFormatter = timeFormatter;
        
        self.selectedMinimumValue = selectedMinVal;
        self.selectedMaximumValue = selectedMaxVal;
        self.maxLimit = selectedMaxVal;
        
        self.selectedColor = [UIColor colorWithRed:(97.0/255.0) green:(189.0/255.0) blue:(250.0/255.0) alpha:1];
        self.unselectedColor = [UIColor colorWithRed:(130.0/255.0) green:(130.0/255.0) blue:(130.0/255.0) alpha:1];
        self.newselectedColor = [UIColor colorWithRed:(0.0/255.0) green:(250.0/255.0) blue:(0.0/255.0) alpha:1];
        
        //track background
        /*
        UIImage* imgNone = [UIImage imageWithImage:[UIImage imageNamed:@"slider_dark_background.png"] scaledToSize:CGSizeMake(w, h_main)];
        self.bubbleBackground = [[UIImageView alloc] initWithImage:imgNone];
        self.bubbleBackground.contentMode = UIViewContentModeLeft;
        
        self.bubbleBackground.frame = self.mainRect;
        
        
        self.bubbleBackground.alpha = self.alpha;
         */
        
        
        //Vert Bar
        UIImage* imgVertBar = [UIImage imageWithImage:[UIImage imageNamed:@"slider_vert_bar.png"] scaledToSize:CGSizeMake(1, h-(3*h_main/4))];
        self.vertBar = [[UIImageView alloc] initWithImage:imgVertBar];
        self.vertBar.contentMode = UIViewContentModeLeft;
        
        self.vertBar.frame = CGRectMake(0,0,1,h-(3*h_main/4));
        
        self.vertBar.alpha = self.alpha;

        [self addSubview:self.vertBar];
        
        //track free
        UIImage* imgWhite = [UIImage imageNamed:@"unselected_bubble.png"];//[UIImage imageWithImage:[UIImage imageNamed:@"unselected_bubble.png"] scaledToSize:CGSizeMake(w, h_main)];
        self.bubbleFree = [[UIImageView alloc] initWithImage:imgWhite];
        self.bubbleFree.clipsToBounds = true;
        self.bubbleFree.frame = self.mainRect;
        self.bubbleFree.alpha = self.alpha;
        
        [self addSubview:self.bubbleFree];
        
        //track booked
        UIImage* imgBlue =[UIImage imageNamed:@"selected_bubble.png"];//[UIImage imageWithImage:[UIImage imageNamed:@"selected_bubble.png"] scaledToSize:CGSizeMake(w, h_main)];
        UIImageView* bubbleBookedImgView = [[UIImageView alloc] initWithImage:imgBlue];
        
        bubbleBookedImgView.frame = self.mainRect;
        bubbleBookedImgView.alpha = self.alpha;
        
        self.bubbleBooked = [[UIView alloc] initWithFrame:frame];
        [self.bubbleBooked addSubview:bubbleBookedImgView];
        [self.bubbleBooked setAutoresizesSubviews:false];
        [self.bubbleBooked setClipsToBounds:true];
        
        [self addSubview:self.bubbleBooked];
        
        UIImage* imgGreen =[UIImage imageNamed:@"selected_bubble_green.png"];//[UIImage imageWithImage:[UIImage imageNamed:@"selected_bubble.png"] scaledToSize:CGSizeMake(w, h_main)];
        
        self.bubbleNewBackground = [[UIImageView alloc] initWithImage:imgGreen];
        self.bubbleNewBackground.clipsToBounds = true;
        self.bubbleNewBackground.frame = self.mainRect;
        self.bubbleNewBackground.alpha = self.alpha;
        
        [self addSubview:self.bubbleNewBackground];
        
        
        
        //labels
        float text_height = (h-h_main)/4;
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,text_height,w-5,text_height)];
        self.timeLabel.textColor = self.selectedColor;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:text_height*1.2];
        self.timeLabel.text = self.timeFormatter(self.minimumValue);
        self.timeLabel.textAlignment = UITextAlignmentLeft;
        
        self.timeLabel.frame = CGRectMake(3,text_height,w-3,text_height);
        [self addSubview:self.timeLabel];
        
        
        Formatter dateFormatter = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"ha"];
            
            if([[dateFormatter stringFromDate:time] isEqualToString:@"12AM"]) {
                [dateFormatter setDateFormat:@"EEEE"];
                NSString* a = [dateFormatter stringFromDate:time];
                return a;
            } else {
                return @"";
            }
            
        };
        
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,0,(2*w)-5,text_height)];
        self.dateLabel.textColor = self.selectedColor;
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:text_height*1.2];
        self.dateLabel.text = dateFormatter(self.minimumValue);
        self.dateLabel.textAlignment = UITextAlignmentLeft;
        
        
        self.dateLabel.frame = CGRectMake(3,0,(2*w)-3,text_height);
        
        [self addSubview:self.dateLabel];
        
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(1,0,w-1,12)];
        self.priceLabel.textColor = self.selectedColor;
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        self.priceLabel.minimumFontSize = 9;
        [self.priceLabel setAdjustsFontSizeToFitWidth:true];
        self.priceLabel.text = [self priceString]; //self.timeFormatter(self.maximumValue);
        self.priceLabel.textAlignment = UITextAlignmentCenter;
        self.priceLabel.center = CGPointMake(w/2, (h-(3*h_main/4)));        self.priceLabel.shadowOffset = CGSizeMake(0,-1);
        
        [self addSubview:self.priceLabel];
        
        //Adust everything!
        [self updateTrackHighlight];
    }
    return self;
}

-(NSString*) priceString {
    if(!self.priceSource) {
        return @"";
    }
    NSArray* prices = [self.priceSource findPricesInRange:self.minimumValue + 60*5 endTime:self.maximumValue - 60*5];
    if(!prices || prices.count == 0) {
        return @"";
    } else if (prices.count == 1) {
        return self.priceFormatter([[prices objectAtIndex:0] doubleValue]);
    } else {
        return @"/";
    }
}

//I suggest you don't use this one.
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame: frame minVal:0 maxVal:1 minRange:0.1 selectedMinVal:0.1 selectedMaxVal:0.9 withPriceFormatter:^NSString *(double val) {
        return @"DEFAULT";
    } withTimeFormatter:^NSString *(double val) {
        return @"DEFAULT";
    } withPriceSource:nil withMinimumSelectedValue:0];
}


-(double)xForValue:(double)value {
    double normalizedValue = (value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    double x = (self.frame.size.width) * normalizedValue;
    return x;
}
-(double)valueForX:(double)x {
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
    
    
    
    double begin = [self xForValue:self.selectedMinimumValue];
    double blueedn = [self xForValue:self.minimumSelectedValue];
    double end = [self xForValue:self.selectedMaximumValue];
    

    
   /* 
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(begin,0,end-begin ,self.bubbleBooked.frame.size.height);
    CGRect rect = CGRectMake(begin,0,end-begin ,self.bubbleBooked.frame.size.height);
    maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"maskImage.png"] CGImage];

    */
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(begin,0,end-begin ,self.bubbleBooked.frame.size.height);
    maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"maskImage.png"] CGImage];

    
    self.bubbleBooked.layer.mask = maskLayer;
    
    [self.bubbleBooked setNeedsDisplay];
    
    CALayer* maskLayertwo = [CALayer layer];
    maskLayertwo.frame = CGRectMake(blueedn,0,end-blueedn ,self.bubbleBooked.frame.size.height);
    NSLog(@"The frame is %@", NSStringFromCGRect(maskLayertwo.frame));
    maskLayertwo.contents = (__bridge id)[[UIImage imageNamed:@"maskImage.png"] CGImage];

    [self.bubbleNewBackground.layer setMask:maskLayertwo];
    [self.bubbleNewBackground setNeedsDisplay];
    
    //NOW labels!
    
    if(end-begin > 0) {
        self.timeLabel.textColor = self.selectedColor;
        self.dateLabel.textColor = self.selectedColor;
        self.priceLabel.textColor = [UIColor whiteColor];
        self.priceLabel.shadowColor = [UIColor blackColor];
    } else {
        self.timeLabel.textColor = self.unselectedColor;
        self.dateLabel.textColor = self.unselectedColor;
        self.priceLabel.textColor = self.unselectedColor;
        self.priceLabel.shadowColor = [UIColor clearColor];
    }
    
    
   
    
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

