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

#define THUMB_DIAMETER 44
#define THUMB_TOUCH_DIAMETER 44
//#define EFFECTIVE_THUMB_DIAMETER 44

#define TRACK_PADDING_VERT 0.0
#define TRACK_PADDING_HORIZ 0.0

#define NUM_INTERVALS_PER_BUBBLE 2.0

#define MAX_SCROLL_SPEED 8.0
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
@property float padding;
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
@synthesize displayedRange = _displayedRange;
@synthesize maxLimit = _maxLimit;
@synthesize selectedMinimumValue = _selectedMinimumValue;
@synthesize selectedMaximumValue = _selectedMaximumValue;


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

@synthesize labelFormatter = _labelFormatter;
@synthesize animating = _animating;
@synthesize scrollVel = _scrollVel;

-(Formatter)labelFormatter {
    if(!_labelFormatter) {
        _labelFormatter = ^(double val) {
            return [NSString stringWithFormat:@"%0.2f", val]; };
    }
    return _labelFormatter;
}

- (RangeBar*)initWithFrame:(CGRect)frame minVal:(double)minVal maxVal:(double)maxVal minRange:(double)minRange displayedRange:(double)displayedRange selectedMinVal:(double)selectedMinVal selectedMaxVal:(double)selectedMaxVal withValueFormatter:(Formatter)formatter {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
        
        self.minimumValue = minVal;
        self.maximumValue = maxVal;
        self.minimumRange = minRange;
        self.displayedRange = displayedRange;
        
        
        self.labelFormatter = formatter;
        
        //for now
        self.selectedMinimumValue = selectedMinVal;
        self.selectedMaximumValue = selectedMaxVal;
        
        
        self.scrollPos = 0;
        
        //track background
        
        
        //okay, how many do we want???
        // we want (maxVal-minVal)/(minRange*NUM_INTERVALS_PER_BUBBLE) bubbles.
        
        float bubbleRange = self.minimumRange*NUM_INTERVALS_PER_BUBBLE;
        
        float cappedDisplayedRange = MIN(self.displayedRange, maxVal-minVal);
        
        self.numDisplayedBubbles = round((cappedDisplayedRange)/bubbleRange);
        
        
        
        self.trackRect = CGRectMake(frame.origin.x + TRACK_PADDING_HORIZ,
                                    frame.origin.y + TRACK_PADDING_HORIZ,
                                    frame.size.width - 2*TRACK_PADDING_HORIZ,
                                    frame.size.height - 2*TRACK_PADDING_VERT);
        
        
        CGRect bubbleRect = CGRectMake(0,0,[self bubbleWidth], self.trackRect.size.height);
        
        self.trackBubbles = [[NSMutableArray alloc] init];
        for (int i = 0; i< self.numDisplayedBubbles; i++) {
            float minVal = self.minimumValue + (bubbleRange*i);
            float maxVal = self.minimumValue + (bubbleRange*(i+1));
            float selectedMinVal = MAX(minVal, self.selectedMinimumValue);
            float selectedMaxVal = MIN(maxVal, self.selectedMaximumValue);
            
            RangeBubble* bubble = [[RangeBubble alloc] initWithFrame:bubbleRect minVal:minVal maxVal:maxVal minRange:self.minimumRange selectedMinVal:selectedMinVal selectedMaxVal:selectedMaxVal withPriceFormatter:^NSString *(double val) {
                return @"";
            } withTimeFormatter:^NSString *(double val) {
                return @"";
            }];
            [self addSubview:bubble];
            [self.trackBubbles addObject:bubble];
        }
        
        [self adjustBubbles];
    

        
        //[self updateMinLabel];
        //[self updateMaxLabel];
    }
    return self;
}

//I suggest you don't use this one.
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame minVal:0 maxVal:1 minRange:0.01 displayedRange:10 selectedMinVal:0 selectedMaxVal:1 withValueFormatter:^(double val){return @"";}];
}

-(float)xForValue:(float)value {
    value = value - self.scrollPos;
    float normalizedValue = (value - self.minimumValue) / (self.displayedRange);
    float x = (self.trackRect.size.width) * normalizedValue + self.padding;
    return x;
}
-(float)valueForX:(float)x {
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
    //we don't allow moving this one for now.
    //Also, be careful: this case is deprecated...
    
    
    double leftScrollDist = touchPoint.x;
    double rightScrollDist = self.frame.size.width - touchPoint.x;
    
    if (leftScrollDist < SCROLL_RANGE) {
        leftScrollDist = MAX(leftScrollDist, 0);
        float unitVel = - (MIN_SCROLL_SPEED + LIN_SCROLL_RATE * (SCROLL_RANGE - leftScrollDist));
        self.scrollVel = self.minimumRange * unitVel;
        [self animateBubbles];
        return;
    } else if (rightScrollDist < SCROLL_RANGE) {
        rightScrollDist = MAX(rightScrollDist, 0);
        float unitVel = MIN_SCROLL_SPEED + LIN_SCROLL_RATE * (SCROLL_RANGE - rightScrollDist);
        self.scrollVel = self.minimumRange * unitVel;
        [self animateBubbles];
        return;
    } else {
        self.scrollVel = 0;
    }
    
    if(false){
        
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
    //if(self.maxThumbOn){
    if(true){
        double lowVal = self.selectedMinimumValue;
        double delVal = [self valueForX:touchPoint.x] - lowVal;
        
        if(delVal >= 0) {
            delVal = delVal + self.minimumRange/2.0 - fmodf(delVal+self.minimumRange/2.0, self.minimumRange); //snap to nearest one
        } else {
            delVal = delVal - self.minimumRange/2.0 - fmodf(delVal-self.minimumRange/2.0, self.minimumRange);
        }
        
        double newVal = lowVal + delVal;
        newVal = MIN(newVal, self.maximumValue);
        newVal = MAX(newVal, self.selectedMinimumValue + self.minimumRange);
        
        if(newVal <= self.maximumValue) {
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
    for(RangeBubble* bubble in self.trackBubbles) {
        bubble.selectedMinimumValue = self.selectedMinimumValue;
        bubble.selectedMaximumValue = self.selectedMaximumValue;
    }
    
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

// gives the width of each bubble given the current track parameters.
- (float) bubbleWidth {
    return self.trackRect.size.width/ self.numDisplayedBubbles;
}

// gives the frame origin for the corresponding bubble.
- (CGRect) frameForBubble:(RangeBubble*)bubble {
    
    float y = self.trackRect.origin.y;
    float x = [self xForValue:bubble.minimumValue];
    float w = [self bubbleWidth];
    float h = self.trackRect.size.height;
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
    
    float bubbleRange = self.minimumRange*NUM_INTERVALS_PER_BUBBLE;
    CGRect bubbleRect = CGRectMake(10000,0,[self bubbleWidth], self.trackRect.size.height);
    
    
    float minVal = lastBubble.maximumValue;
    float maxVal = lastBubble.maximumValue + bubbleRange;
    float selectedMinVal = MAX(minVal, self.selectedMinimumValue);
    float selectedMaxVal = MIN(maxVal, self.selectedMaximumValue);
        
    RangeBubble* bubble = [[RangeBubble alloc] initWithFrame:bubbleRect minVal:minVal maxVal:maxVal minRange:self.      minimumRange selectedMinVal:selectedMinVal selectedMaxVal:selectedMaxVal
                                          withPriceFormatter:^NSString *(double val) {
                                              return @"";
                                          } withTimeFormatter:^NSString *(double val) {
                                              return @"";
                                          }];
    [self addSubview:bubble];
    [self.trackBubbles addObject:bubble];
    
}

- (void) animateBubbles {
    
    if(!self.animating && self.scrollVel!=0) {
        self.animating = true;
        
        // 1 over number of intervals per second
        float period = fabs(self.minimumRange/self.scrollVel);
        
        if(self.scrollVel>0 && [self hasMoreBubblesRight]) {
            self.scrollPos += self.minimumRange;
            [self addMoreBubblesIfNeeded];
        } else if (self.scrollVel<0 && [self hasMoreBubblesLeft]) {
            self.scrollPos -= self.minimumRange;
        } else {
            self.animating = false;
            return;
        }
        
        
        [UIView animateWithDuration:period animations:^{
            [self adjustBubbles];
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
    
    float falloff = 0.1;
    int i = 0;
    for (RangeBubble* bubble in self.trackBubbles) {
        CGRect frame = [self frameForBubble:bubble];
        bubble.frame = frame;
        
        float leftPos = frame.origin.x - (self.trackRect.origin.x + 20);
        float rightPos = (self.trackRect.origin.x + self.trackRect.size.width - 20) - (frame.origin.x+frame.size.width);
        
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
    float bubbleRange = self.minimumRange*NUM_INTERVALS_PER_BUBBLE;
    float totalBubbleRange = (1+ceil((self.maximumValue - self.minimumValue)/bubbleRange))*bubbleRange;
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
