//
//  RangeBar.m
//  Parkify2
//
//  Created by Me on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RangeBar.h"
#import "UIImage+Resize.h"
#import "RangeBubble.h"
#import "ParkingSpot.h"

#define THUMB_DIAMETER 44
#define THUMB_TOUCH_DIAMETER 44
//#define EFFECTIVE_THUMB_DIAMETER 44

#define TRACK_PADDING_VERT 0.0
#define TRACK_PADDING_HORIZ 0.0

#define NUM_INTERVALS_PER_BUBBLE 2.0

#define MAX_SCROLL_SPEED 16.0
#define MIN_SCROLL_SPEED 2.0
#define SCROLL_RANGE 40.0

#define LIN_SCROLL_RATE ((MAX_SCROLL_SPEED - MIN_SCROLL_SPEED) / SCROLL_RANGE )

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
@property double padding;
@property (strong, nonatomic) UIImageView * minThumb;
@property (strong, nonatomic) UIImageView * maxThumb;

@property CGRect trackRect;

@property (strong, nonatomic) NSMutableArray* trackBubbles;

@property (strong, nonatomic) UILabel * minLabel;
@property (strong, nonatomic) UILabel * maxLabel;

@property (strong, nonatomic) UILabel * startTimeLabel;
@property (strong, nonatomic) UILabel * endTimeLabel;

@property (strong, nonatomic) UIImageView * minLabelBackground;
@property (strong, nonatomic) UIImageView * maxLabelBackground;

@property double maxLimit;

@property double scrollPos;
@property double scrollVel;
@property int numDisplayedBubbles;

@property BOOL animating;

@property (strong, nonatomic) NSObject<PriceStore>*  priceSource;

@property CGPoint lastTouchedPoint;


-(double)xForValue:(double)value;
-(double)valueForX:(double)x;

-(void)updateTrackHighlight;


@end

@implementation RangeBar

@synthesize minimumValue = _minimumValue;
@synthesize minimumSelectableValue = _minimumSelectableValue;
@synthesize maximumValue = _maximumValue;
@synthesize minimumRange = _minimumRange;
@synthesize displayedRange = _displayedRange;
@synthesize maxLimit = _maxLimit;
@synthesize selectedMinimumValue = _selectedMinimumValue;
@synthesize selectedMaximumValue = _selectedMaximumValue;
@synthesize timeFormatter = _timeFormatter;
@synthesize priceFormatter = _priceFormatter;

@synthesize maxThumbOn = _maxThumbOn;
@synthesize minThumbOn = _minThumbOn;
@synthesize padding = _padding;
@synthesize minThumb = _minThumb;
@synthesize maxThumb = _maxThumb;
@synthesize minLabel = _minLabel;
@synthesize maxLabel = _maxLabel;
@synthesize startTimeLabel = _startTimeLabel;
@synthesize endTimeLabel = _endTimeLabel;
@synthesize minLabelBackground = _minLabelBackground;
@synthesize maxLabelBackground = _maxLabelBackground;

@synthesize scrollPos = _scrollPos;
@synthesize numDisplayedBubbles = _numDisplayedBubbles;

@synthesize animating = _animating;
@synthesize scrollVel = _scrollVel;

@synthesize priceSource = _priceSource;

@synthesize lastTouchedPoint = _lastTouchedPoint;

- (RangeBar*)initWithFrame:(CGRect)frame minVal:(double)minVal minimumSelectableValue:(double)minSelectVal maxVal:(double)maxVal minRange:(double)minRange displayedRange:(double)displayedRange selectedMinVal:(double)selectedMinVal selectedMaxVal:(double)selectedMaxVal withTimeFormatter:(Formatter)timeFormatter withPriceFormatter:(Formatter)priceFormatter withPriceSource:(NSObject<PriceStore>*)  priceSource{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.priceSource = priceSource;
        
        self.minimumValue = minVal;
        self.minimumSelectableValue = minSelectVal;
        self.maximumValue = maxVal;
        self.minimumRange = minRange;
        self.displayedRange = displayedRange;
        
        
        self.timeFormatter = timeFormatter;
        self.priceFormatter = priceFormatter;
        
        //for now
        self.selectedMinimumValue = selectedMinVal;
        self.selectedMaximumValue = selectedMaxVal;
        
        
        self.scrollPos = 0;
        
        //track background
        
        
        //okay, how many do we want???
        // we want (maxVal-minVal)/(minRange*NUM_INTERVALS_PER_BUBBLE) bubbles.
        
        double bubbleRange = self.minimumRange*NUM_INTERVALS_PER_BUBBLE;
        
        double cappedDisplayedRange = MIN(self.displayedRange, maxVal-minVal);
        
        self.numDisplayedBubbles = round((cappedDisplayedRange)/bubbleRange);
        
        
        
        self.trackRect = CGRectMake(frame.origin.x + TRACK_PADDING_HORIZ,
                                    frame.origin.y + TRACK_PADDING_HORIZ,
                                    frame.size.width - 2*TRACK_PADDING_HORIZ,
                                    frame.size.height - 2*TRACK_PADDING_VERT);
        
        
        CGRect bubbleRect = CGRectMake(0,0,[self bubbleWidth], self.trackRect.size.height);
        
        self.trackBubbles = [[NSMutableArray alloc] init];
        for (int i = 0; i< self.numDisplayedBubbles; i++) {
            double minVal = self.minimumValue + (bubbleRange*i);
            double maxVal = self.minimumValue + (bubbleRange*(i+1));
            double selectedMinVal = MAX(minVal, self.selectedMinimumValue);
            double selectedMaxVal = MIN(maxVal, self.selectedMaximumValue);
            double minselectval = self.minimumSelectableValue + (30*60);
            if(self.minimumSelectableValue == self.minimumValue)
                minselectval = minVal;

            RangeBubble* bubble = [[RangeBubble alloc] initWithFrame:bubbleRect minVal:minVal maxVal:maxVal minRange:self.minimumRange selectedMinVal:selectedMinVal selectedMaxVal:selectedMaxVal withPriceFormatter:self.priceFormatter withTimeFormatter:self.timeFormatter withPriceSource:self.priceSource withMinimumSelectedValue:minselectval];
            [self addSubview:bubble];
            [self.trackBubbles addObject:bubble];
            
        }
        [UIView animateWithDuration:1.0
                         animations:^{
                             [self adjustBubbles];
                         }
                         completion:^(BOOL finished) {}];
        
    

        
    }
    return self;
}

//I suggest you don't use this one.
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame minVal:0 minimumSelectableValue:0 maxVal:1 minRange:0.01 displayedRange:10 selectedMinVal:0 selectedMaxVal:1 withTimeFormatter:^NSString *(double val) {
        return @"";
    } withPriceFormatter:^NSString *(double val) {
        return @"";
    } withPriceSource:nil];
}

-(double)xForValue:(double)value {
    value = value - self.scrollPos;
    double normalizedValue = (value - self.minimumValue) / (self.displayedRange);
    double x = (self.trackRect.size.width) * normalizedValue + self.padding;
    return x;
}
-(double)valueForX:(double)x {
    return self.scrollPos + self.minimumValue + (x-self.padding) / (self.trackRect.size.width) * (self.displayedRange);
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
    
    self.scrollVel = 0;
    
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
                       
    [self doTouchHandler:touchPoint];
    
    if(CGRectContainsPoint(frame, touchPoint)){
        self.maxThumbOn = true;
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
    //if(!self.minThumbOn && !self.maxThumbOn){
    //    return;
    //}
    
    CGPoint touchPoint = [touch locationInView:self];
    [self doTouchHandler:touchPoint];
}



- (void) doTouchHandler:(CGPoint)touchPoint {
    
    double leftScrollDist = touchPoint.x;
    double rightScrollDist = self.frame.size.width - touchPoint.x;
    
    self.lastTouchedPoint = touchPoint;
    
    if ([self hasMoreBubblesLeft] && leftScrollDist < SCROLL_RANGE) {
        leftScrollDist = MAX(leftScrollDist, 0);
        double unitVel = - (MIN_SCROLL_SPEED + LIN_SCROLL_RATE * (SCROLL_RANGE - leftScrollDist));
        self.scrollVel = self.minimumRange * unitVel;
        [self animateBubbles];
    } else if ([self hasMoreBubblesRight] && rightScrollDist < SCROLL_RANGE) {
        rightScrollDist = MAX(rightScrollDist, 0);
        double unitVel = MIN_SCROLL_SPEED + LIN_SCROLL_RATE * (SCROLL_RANGE - rightScrollDist);
        self.scrollVel = self.minimumRange * unitVel;
        [self animateBubbles];
    } else {
        self.scrollVel = 0;
    }
    
    [self updateSelectedValueFromTap:touchPoint];
    
    [self setNeedsDisplay];
}


- (void) updateSelectedValueFromTap:(CGPoint)touchPoint {
    double lowVal = self.selectedMinimumValue;
    double delVal = [self valueForX:touchPoint.x] - lowVal;

    if(delVal >= 0) {
        delVal = delVal + self.minimumRange/2.0 - fmodf(delVal+self.minimumRange/2.0, self.minimumRange); //snap to nearest one
    } else {
        delVal = delVal - self.minimumRange/2.0 - fmodf(delVal-self.minimumRange/2.0, self.minimumRange);
    }

    double newVal = lowVal + delVal;
    newVal = MIN(newVal, self.maximumValue);
    //newVal = MAX(newVal, self.selectedMinimumValue + self.minimumRange);
    newVal = MAX(newVal, self.minimumSelectableValue + self.minimumRange);
    NSLog(@"Value is %f", newVal);
    if(newVal <= self.maximumValue) {
        self.maxThumb.center = CGPointMake([self xForValue:newVal], self.maxThumb.center.y);
        self.selectedMaximumValue = newVal;
        [self updateTrackHighlight];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)updateTrackHighlight{
    /*
    self.track.frame = CGRectMake(self.track.center.x,
                                  self.minThumb.center.y - (self.track.frame.size.height/2),
                                  self.maxThumb.center.x - self.minThumb.center.x, self.track.frame.size.height);    
     */
    int i = 0;
    for(RangeBubble* bubble in self.trackBubbles) {
        bubble.selectedMinimumValue = self.selectedMinimumValue;
        bubble.selectedMaximumValue = self.selectedMaximumValue;
        i++;
    }
    
}

// gives the width of each bubble given the current track parameters.
- (double) bubbleWidth {
    return [self xForValue:(self.minimumValue+self.minimumRange*NUM_INTERVALS_PER_BUBBLE)] - [self xForValue:self.minimumValue];
    //return self.trackRect.size.width/ self.numDisplayedBubbles;
}

// gives the frame origin for the corresponding bubble.
- (CGRect) frameForBubble:(RangeBubble*)bubble {
    
    double y = self.trackRect.origin.y;
    double x = [self xForValue:bubble.minimumValue];
    double w = [self bubbleWidth];
    double h = self.trackRect.size.height;
    return CGRectMake(x,y,w,h);
}

- (void) addMoreBubblesIfNeeded {
    if(!self.trackBubbles || self.trackBubbles.count <= 0) {
        return;
    }
    
    RangeBubble* lastBubble = self.trackBubbles.lastObject;
    
    //check if we need another bubble. Is is the largest shown value represented in our shown bubbles?
    if (self.minimumValue + self.scrollPos + self.displayedRange < lastBubble.maximumValue) {
        return;
    }
    
    double bubbleRange = self.minimumRange*NUM_INTERVALS_PER_BUBBLE;
    
    double bubbleWidth = [self xForValue:(self.minimumValue+bubbleRange)] - [self xForValue:self.minimumValue];
    CGRect bubbleRect = CGRectMake(0,0,[self bubbleWidth], self.trackRect.size.height);

    
    double minVal = lastBubble.maximumValue;
    double maxVal = lastBubble.maximumValue + bubbleRange;
    double selectedMinVal = self.selectedMinimumValue;
    double selectedMaxVal = self.selectedMaximumValue;
    double minselectval = self.minimumSelectableValue + (30*60);
    if(self.minimumSelectableValue == self.minimumValue)
        minselectval = minVal;
    RangeBubble* bubble = [[RangeBubble alloc] initWithFrame:bubbleRect minVal:minVal maxVal:maxVal minRange:self.      minimumRange selectedMinVal:selectedMinVal selectedMaxVal:selectedMaxVal
                                          withPriceFormatter:self.priceFormatter withTimeFormatter:self.timeFormatter withPriceSource:self.priceSource withMinimumSelectedValue:minselectval];
    [self addSubview:bubble];
    [self.trackBubbles addObject:bubble];
    
    CGRect frame = [self frameForBubble:bubble];
    bubble.frame = frame;
    
}

- (void) animateBubbles {
    
    if(!self.animating && self.scrollVel!=0) {
        self.animating = true;
        
        // 1 over number of intervals per second
        double period = fabs(self.minimumRange/self.scrollVel);
        
        if(self.scrollVel>0 && [self hasMoreBubblesRight]) {
            self.scrollPos += self.minimumRange;
            [self addMoreBubblesIfNeeded];
        } else if (self.scrollVel<0 && [self hasMoreBubblesLeft]) {
            self.scrollPos -= self.minimumRange;
        } else {
            self.animating = false;
            return;
        }
        
        
        [UIView animateWithDuration:period
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
            [self adjustBubbles];
            [self updateSelectedValueFromTap:self.lastTouchedPoint];
            
        }
        completion:^(BOOL finished) {
            self.animating = false;
            [self animateBubbles];
        }];
        
    }
    
}

- (void) adjustBubbles {
    //TODO: adjust bubble size if certain parameters were changed
    
    //move each bubble to the appropriate position
    
    double falloff = 0.1;
    int i = 0;
    for (RangeBubble* bubble in self.trackBubbles) {
        CGRect frame = [self frameForBubble:bubble];
        bubble.frame = frame;
        
        double leftPos = frame.origin.x - (self.trackRect.origin.x + 20);
        double rightPos = (self.trackRect.origin.x + self.trackRect.size.width - 20) - (frame.origin.x+frame.size.width);
        
        if ([self hasMoreBubblesLeft] && leftPos < 0) {
            [bubble setAlpha:MIN(1, (1/(-leftPos*falloff)) )];
        } else if ([self hasMoreBubblesRight] && rightPos < 0) {
            [bubble setAlpha:MIN(1, (1/(-rightPos*falloff)) )];
        } else {
            [bubble setAlpha:1];
        }
        i++;
    }
}

//Check to see if we can scroll left
- (BOOL)hasMoreBubblesLeft {
    return self.scrollPos > 0;
}

- (BOOL)hasMoreBubblesRight {
    double bubbleRange = self.minimumRange*NUM_INTERVALS_PER_BUBBLE;
    double totalBubbleRange = (ceil((self.maximumValue - self.minimumValue)/bubbleRange))*bubbleRange;
    return (self.scrollPos + self.displayedRange) <= totalBubbleRange;
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
