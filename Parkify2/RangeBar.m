//
//  RangeBar.m
//  Parkify2
//
//  Created by Me on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RangeBar.h"
#import "UIImage+Resize.h"

#define THUMB_DIAMETER 44
#define THUMB_TOUCH_DIAMETER 44
//#define EFFECTIVE_THUMB_DIAMETER 44

#define TRACK_PADDING_VERT 20
#define TRACK_PADDING_HORIZ 20


/* //Not Used
#define ORIG_TRACK_BACKGROUND_WIDTH 579
#define ORIG_TRACK_BACKGROUND_HEIGHT 88

#define ORIG_WORKABLE_AREA_X 105
#define ORIG_WORKABLE_AREA_Y 12
#define ORIG_WORKABLE_AREA_WIDTH 441
#define ORIG_WORKABLE_AREA_HEIGHT 28//64

#define WORKABLE_AREA_X (ORIG_WORKABLE_AREA_X*0.5)
#define WORKABLE_AREA_Y (ORIG_WORKABLE_AREA_Y*0.5)
#define WORKABLE_AREA_WIDTH (ORIG_WORKABLE_AREA_WIDTH*0.5)
#define WORKABLE_AREA_HEIGHT (ORIG_WORKABLE_AREA_HEIGHT*0.5)


#define TRACK_WIDTH 271// 20
#define TRACK_HEIGHT 20// 271
#define TRACK_BACKGROUND_WIDTH (frame.size.width)//WORKABLE_AREA_WIDTH
#define TRACK_BACKGROUND_HEIGHT (frame.size.height)
*/ 

#define CALLOUT_HEIGHT_MAIN (70*0.42)//(55*0.42)
#define CALLOUT_HEIGHT_ARROW (35*0.42)
#define CALLOUT_HEIGHT (CALLOUT_HEIGHT_MAIN+CALLOUT_HEIGHT_ARROW)
#define CALLOUT_WIDTH (142*0.45) //93

#define CALLOUT_OFFSET_VERTICAL -3
#define CALLOUT_OFFSET_HORIZONTAL   0

#define CALLOUT_TEXT_SIZE 13
#define CALLOUT_TEXT_COLOR [UIColor colorWithRed:226.0/255 green:226.0/255 blue:226.0/255 alpha:1]

#define LABEL_TO_LABEL_VERTICAL_OFFSET (-CALLOUT_HEIGHT_MAIN + 5)
@interface RangeBar()   

@property BOOL maxThumbOn;
@property BOOL minThumbOn;
@property float padding;
@property (strong, nonatomic) UIImageView * minThumb;
@property (strong, nonatomic) UIImageView * maxThumb;
@property (strong, nonatomic) UIImageView * track_booked;
@property (strong, nonatomic) UIImageView * track_free;
@property (strong, nonatomic) UIImageView * trackBackground;
@property (strong, nonatomic) UILabel * minLabel;
@property (strong, nonatomic) UILabel * maxLabel;

@property (strong, nonatomic) UILabel * startTimeLabel;
@property (strong, nonatomic) UILabel * endTimeLabel;

@property (strong, nonatomic) UIImageView * minLabelBackground;
@property (strong, nonatomic) UIImageView * maxLabelBackground;

@property double maxLimit;

-(float)xForValue:(float)value;
-(float)valueForX:(float)x;

-(void)updateTrackHighlight;
-(void)updateMinLabel;
-(void)updateMaxLabel;


@end

@implementation RangeBar

@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize minimumRange = _minimumRange;
@synthesize maxLimit = _maxLimit;
@synthesize selectedMinimumValue = _selectedMinimumValue;
@synthesize selectedMaximumValue = _selectedMaximumValue;


@synthesize maxThumbOn = _maxThumbOn;
@synthesize minThumbOn = _minThumbOn;
@synthesize padding = _padding;
@synthesize minThumb = _minThumb;
@synthesize maxThumb = _maxThumb;
@synthesize track_booked = _track_booked;
@synthesize track_free = _free;
@synthesize trackBackground = _trackBackground;
@synthesize minLabel = _minLabel;
@synthesize maxLabel = _maxLabel;
@synthesize startTimeLabel = _startTimeLabel;
@synthesize endTimeLabel = _endTimeLabel;
@synthesize minLabelBackground = _minLabelBackground;
@synthesize maxLabelBackground = _maxLabelBackground;

@synthesize labelFormatter = _labelFormatter;

-(Formatter)labelFormatter {
    if(!_labelFormatter) {
        _labelFormatter = ^(double val) {
            return [NSString stringWithFormat:@"%0.2f", val]; };
    }
    return _labelFormatter;
}

- (RangeBar*)initWithFrame:(CGRect)frame minVal:(double)minVal maxVal:(double)maxVal minRange:(double)minRange selectedMaxVal:(double)selectedMaxVal withValueFormatter:(Formatter)formatter {
    self = [super initWithFrame:frame];
    if (self) {
        
        double w = frame.size.width - 2*TRACK_PADDING_HORIZ;
        double h = frame.size.height - 2*TRACK_PADDING_VERT;
        
        self.minimumValue = minVal;
        self.maximumValue = maxVal;
        self.minimumRange = minRange;
        self.labelFormatter = formatter;
        
        //for now
        self.selectedMinimumValue = self.minimumValue;
        self.selectedMaximumValue = self.minimumValue + self.minimumRange;
        self.maxLimit = selectedMaxVal;
        
        //track background
        UIImage* imgRed = [UIImage imageWithImage:[UIImage imageNamed:@"slider_dark_background.png"] scaledToSize:CGSizeMake(w, h)];
        self.trackBackground = [[UIImageView alloc] initWithImage:imgRed];
        self.trackBackground.contentMode = UIViewContentModeLeft;
        
        self.trackBackground.frame = CGRectMake((frame.size.width - w) / 2, (frame.size.height - h) / 2, w, h);
        self.trackBackground.alpha = 0.75;
        [self addSubview:self.trackBackground];
        
        self.padding = (frame.size.width - self.trackBackground.frame.size.width) / 2.0; 
        
        //track free
        UIImage* imgWhite = [UIImage imageWithImage:[UIImage imageNamed:@"slider_white_background.png"] scaledToSize:CGSizeMake(w, h)];
        self.track_free = [[UIImageView alloc] initWithImage:imgWhite];
        self.track_free.contentMode = UIViewContentModeLeft;
        self.track_free.autoresizingMask = UIViewAutoresizingNone;
        self.track_free.clipsToBounds = true;
        
        self.track_free.frame = CGRectMake(self.padding, (frame.size.height - h) / 2, [self xForValue:self.maxLimit] - self.padding, h);
        [self addSubview:self.track_free];
        
        //track booked
        UIImage* imgBlue = [UIImage imageWithImage:[UIImage imageNamed:@"slider_blue_background.png"] scaledToSize:CGSizeMake(w, h)];
        self.track_booked = [[UIImageView alloc] initWithImage:imgBlue];
        self.track_booked.contentMode = UIViewContentModeLeft;
        self.track_booked.autoresizingMask = UIViewAutoresizingNone;
        self.track_booked.clipsToBounds = true;
        
        self.track_booked.frame = CGRectMake(self.padding, (frame.size.height - h) / 2, [self xForValue:self.selectedMaximumValue] - self.padding, h);
        self.track_booked.alpha = 0.75;
        
        [self addSubview:self.track_booked];
        
        
        //minThumb
        self.minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        
        self.minThumb.frame = CGRectMake(0,0, THUMB_DIAMETER,THUMB_DIAMETER);
        self.minThumb.contentMode = UIViewContentModeScaleAspectFit;
        self.minThumb.center = CGPointMake([self xForValue:self.selectedMinimumValue], frame.size.height / 2);
        [self addSubview:self.minThumb];
        
        //maxThumb
        self.maxThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_thumb.png"]];
        
        self.maxThumb.frame = CGRectMake(0,0, THUMB_DIAMETER,THUMB_DIAMETER);
        self.maxThumb.contentMode = UIViewContentModeScaleAspectFit;
        self.maxThumb.center = CGPointMake([self xForValue:self.selectedMaximumValue], frame.size.height / 2);
        [self addSubview:self.maxThumb];
        
        //Label Backgrounds
        self.minLabelBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"callout_time_label.png"]];
        self.minLabelBackground.frame = CGRectMake(0,0, CALLOUT_WIDTH, CALLOUT_HEIGHT_MAIN);
        [self addSubview:self.minLabelBackground];
        
        self.maxLabelBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_callout_background.png"]];
        self.maxLabelBackground.frame = CGRectMake(0,0, CALLOUT_WIDTH, CALLOUT_HEIGHT);
        [self addSubview:self.maxLabelBackground];
        
        
        //Labels
        self.minLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,28)];
        self.minLabel.textColor = CALLOUT_TEXT_COLOR;
        self.minLabel.backgroundColor = [UIColor clearColor];
        self.minLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(CALLOUT_TEXT_SIZE)];
        self.minLabel.text = @"";
        [self.minLabelBackground addSubview:self.minLabel];
        
        self.maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,35)];
        self.maxLabel.textColor = CALLOUT_TEXT_COLOR;
        self.maxLabel.backgroundColor = [UIColor clearColor];
        self.maxLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(CALLOUT_TEXT_SIZE)];
        self.maxLabel.text = @"";
        [self.maxLabelBackground addSubview:self.maxLabel];
        
        self.startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,35)];
        self.startTimeLabel.textColor = CALLOUT_TEXT_COLOR;
        self.startTimeLabel.backgroundColor = [UIColor clearColor];
        self.startTimeLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(CALLOUT_TEXT_SIZE)];
        self.startTimeLabel.text = @"Start Time";
        self.startTimeLabel.textAlignment = UITextAlignmentCenter;
        [self.minLabelBackground addSubview:self.startTimeLabel];
        
        self.endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,35)];
        self.endTimeLabel.textColor = CALLOUT_TEXT_COLOR;
        self.endTimeLabel.backgroundColor = [UIColor clearColor];
        self.endTimeLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(CALLOUT_TEXT_SIZE)];
        self.endTimeLabel.text = @"End Time";
        self.endTimeLabel.textAlignment = UITextAlignmentCenter;
        [self.maxLabelBackground addSubview:self.endTimeLabel];
        
        
        
    

        
        [self updateMinLabel];
        [self updateMaxLabel];
        //self.minLabelBackground.alpha = 0;
        //self.maxLabelBackground.alpha = 0;
    }
    return self;
}

//I suggest you don't use this one.
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame minVal:0 maxVal:1 minRange:0.01 selectedMaxVal:1 withValueFormatter:^(double val){return @"";}];
}

-(float)xForValue:(float)value {
    float normalizedValue = (value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    float x = (self.frame.size.width - (self.padding * 2)) * normalizedValue + self.padding;
    return x;
}
-(float)valueForX:(float)x {
    return self.minimumValue + (x-self.padding) / (self.frame.size.width-(self.padding*2)) * (self.maximumValue - self.minimumValue);
}


- (void) handleEndTouch {
    /*
    if(self.minThumbOn) {
        [UIView animateWithDuration:.5
                         animations: ^{[self.minLabelBackground setAlpha:0];}
                         completion: ^(BOOL finished){}];
    }
    if(self.maxThumbOn) {
        [UIView animateWithDuration:.5
                         animations: ^ {
                             [self.maxLabelBackground setAlpha:0];
                         }
                         completion: ^ (BOOL finished) {
                         }];
    }
     */
    self.minThumbOn = false;
    self.maxThumbOn = false;
}

//for now, don't worry about multiple touches.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch;
    for( UITouch* t in touches) {
        touch = t;
    }
    CGPoint touchPoint = [touch locationInView:self];
    
    /*
    if(CGRectContainsPoint(self.minThumb.frame, touchPoint)){
        _minThumbOn = true;
    }else if(CGRectContainsPoint(self.maxThumb.frame, touchPoint)){
        _maxThumbOn = true;
    }*/
    
    CGRect frame = self.maxThumb.frame;
    frame.origin.x += (frame.size.width-THUMB_TOUCH_DIAMETER)/2;
    frame.origin.y -= (frame.size.height-THUMB_TOUCH_DIAMETER)/2;
    frame.size = CGSizeMake(THUMB_TOUCH_DIAMETER, THUMB_TOUCH_DIAMETER);
                       
    
    
    if(CGRectContainsPoint(frame, touchPoint)){
        _maxThumbOn = true;
    }
    
    
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleEndTouch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleEndTouch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch;
    for( UITouch* t in touches) {
        touch = t;
    }
    if(!self.minThumbOn && !self.maxThumbOn){
        return;
    }
    
    CGPoint touchPoint = [touch locationInView:self];
    if(self.minThumbOn){
        
        double oldVal = self.selectedMinimumValue;
        double delVal = [self valueForX:touchPoint.x] - oldVal;
        
        if(delVal >= 0) {
            delVal = delVal + self.minimumRange/2.0 - fmodf(delVal+self.minimumRange/2.0, self.minimumRange); //snap to nearest one
        } else {
            delVal = delVal - self.minimumRange/2.0 - fmodf(delVal-self.minimumRange/2.0, self.minimumRange); 
        }
        
        double newVal = oldVal + delVal;
        
        
        newVal = MAX(newVal, self.minimumValue);
        newVal = MIN(newVal, self.selectedMaximumValue - self.minimumRange);
        
        self.minThumb.center = CGPointMake([self xForValue:newVal], self.minThumb.center.y);
        [self updateMinLabel];
        
        self.selectedMinimumValue = newVal;
        [self updateTrackHighlight];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    if(self.maxThumbOn){
        double oldVal = self.selectedMaximumValue;
        double delVal = [self valueForX:touchPoint.x] - oldVal;
        
        if(delVal >= 0) {
            delVal = delVal + self.minimumRange/2.0 - fmodf(delVal+self.minimumRange/2.0, self.minimumRange); //snap to nearest one
        } else {
            delVal = delVal - self.minimumRange/2.0 - fmodf(delVal-self.minimumRange/2.0, self.minimumRange); 
        }
        
        double newVal = oldVal + delVal;
        newVal = MIN(newVal, self.maximumValue);
        newVal = MAX(newVal, self.selectedMinimumValue + self.minimumRange);
        
        if(newVal <= self.maxLimit) {
            self.maxThumb.center = CGPointMake([self xForValue:newVal], self.maxThumb.center.y);
            [self updateMaxLabel];
            self.selectedMaximumValue = newVal;
            [self updateTrackHighlight];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    //NSLog(@"diff:%f", [self valueForY:self.maxThumb.center.y]-[self valueForY:self.minThumb.center.y]);
    //NSLog(@"Min: %f, Max: %f", [self valueForY:self.minThumb.center.y], [self valueForY:self.maxThumb.center.y]);
    [self setNeedsDisplay]; 
}

- (void)updateTrackHighlight{
    /*
    self.track.frame = CGRectMake(self.track.center.x,
                                  self.minThumb.center.y - (self.track.frame.size.height/2),
                                  self.maxThumb.center.x - self.minThumb.center.x, self.track.frame.size.height);    
     */
    self.track_booked.frame = CGRectMake(self.minThumb.center.x,
                                  self.minThumb.center.y - (self.track_booked.frame.size.height/2),
                                  self.maxThumb.center.x - self.minThumb.center.x, self.track_booked.frame.size.height);  
}

-(void)updateMinLabel {
    NSString* strToSet = self.labelFormatter(self.selectedMinimumValue);
    CGSize expectedLabelSize = [strToSet sizeWithFont:self.minLabel.font];
    self.minLabel.frame = CGRectMake( (CALLOUT_WIDTH - expectedLabelSize.width)/2, (CALLOUT_HEIGHT_MAIN - expectedLabelSize.height)/2, expectedLabelSize.width , expectedLabelSize.height);
    self.minLabel.text = strToSet;

     /*
    self.minLabelBackground.frame = CGRectMake([self xForValue:self.minimumValue]-self.minLabelBackground.frame.size.width + CALLOUT_OFFSET_HORIZONTAL,
                                               self.maxThumb.center.y - self.maxThumb.frame.size.height/2 - CALLOUT_HEIGHT + CALLOUT_OFFSET_VERTICAL,
                                               self.minLabelBackground.frame.size.width,
                                               self.minLabelBackground.frame.size.height);
     */
    
    
    
     self.minLabelBackground.frame = CGRectMake([self xForValue:self.minimumValue]-(self.minLabelBackground.frame.size.width/2) + CALLOUT_OFFSET_HORIZONTAL,
     self.maxThumb.center.y - self.maxThumb.frame.size.height/2 - CALLOUT_HEIGHT + CALLOUT_OFFSET_VERTICAL,
     self.minLabelBackground.frame.size.width,
     self.minLabelBackground.frame.size.height);
     

    [self.minLabelBackground setAlpha:1];
    
    self.startTimeLabel.center = CGPointMake(self.minLabel.center.x, self.minLabel.center.y + LABEL_TO_LABEL_VERTICAL_OFFSET);
    
}

-(void)updateMaxLabel {
    NSString* strToSet = self.labelFormatter(self.selectedMaximumValue);
    CGSize expectedLabelSize = [strToSet sizeWithFont:self.maxLabel.font];
    
    
    self.maxLabel.frame = CGRectMake( (CALLOUT_WIDTH - expectedLabelSize.width)/2, (CALLOUT_HEIGHT_MAIN - expectedLabelSize.height)/2, expectedLabelSize.width , expectedLabelSize.height);
    self.maxLabel.text = strToSet;
    
    
    double newX = self.maxThumb.center.x - self.maxLabelBackground.frame.size.width/2 + CALLOUT_OFFSET_HORIZONTAL;
    double newXConstrained = [self xForValue:self.minimumValue]+(CALLOUT_WIDTH/2);
    

    if(newX <= newXConstrained) {
        newX = newXConstrained;
        self.maxLabelBackground.image = [UIImage imageNamed:@"callout_time_label.png"];
        
        self.maxLabelBackground.frame = CGRectMake(newX,
                                                   self.maxThumb.center.y - self.maxThumb.frame.size.height/2 - CALLOUT_HEIGHT + CALLOUT_OFFSET_VERTICAL,
                                                   self.maxLabelBackground.frame.size.width,
                                                   CALLOUT_HEIGHT_MAIN);
        
    } else {
        self.maxLabelBackground.image = [UIImage imageNamed:@"slider_callout_background.png"];
        
        self.maxLabelBackground.frame = CGRectMake(newX,
                                                   self.maxThumb.center.y - self.maxThumb.frame.size.height/2 - CALLOUT_HEIGHT + CALLOUT_OFFSET_VERTICAL,
                                                   self.maxLabelBackground.frame.size.width,
                                                   CALLOUT_HEIGHT);
        
    }
                                                                  
                                                                  
    
    
    
    self.endTimeLabel.center = CGPointMake(self.maxLabel.center.x, self.maxLabel.center.y + LABEL_TO_LABEL_VERTICAL_OFFSET);
    //[self.maxLabelBackground setAlpha:1];
    
    /*
     
     self.maxLabel.text = self.labelFormatter(self.selectedMaximumValue);
     self.maxLabel.frame = CGRectMake(self.maxThumb.center.x + self.maxThumb.frame.size.width/2,
     self.maxThumb.center.y - self.maxLabel.frame.size.height/2,
     self.maxLabel.frame.size.width,
     self.maxLabel.frame.size.height);
     */ 
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
