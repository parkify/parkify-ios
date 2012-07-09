//
//  RangeBar.m
//  Parkify2
//
//  Created by Me on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RangeBar.h"

#define EFFECTIVE_THUMB_DIAMETER 44

@interface RangeBar() 

@property BOOL maxThumbOn;
@property BOOL minThumbOn;
@property float padding;
@property (strong, nonatomic) UIImageView * minThumb;
@property (strong, nonatomic) UIImageView * maxThumb;
@property (strong, nonatomic) UIImageView * track;
@property (strong, nonatomic) UIImageView * trackBackground;
@property (strong, nonatomic) UILabel * minLabel;
@property (strong, nonatomic) UILabel * maxLabel;


-(float)yForValue:(float)value;
-(float)valueForY:(float)y;
-(void)updateTrackHighlight;
-(void)updateMinLabel;
-(void)updateMaxLabel;


@end

@implementation RangeBar

@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize minimumRange = _minimumRange;
@synthesize selectedMinimumValue = _selectedMinimumValue;
@synthesize selectedMaximumValue = _selectedMaximumValue;

@synthesize maxThumbOn = _maxThumbOn;
@synthesize minThumbOn = _minThumbOn;
@synthesize padding = _padding;
@synthesize minThumb = _minThumb;
@synthesize maxThumb = _maxThumb;
@synthesize track = _track;
@synthesize trackBackground = _trackBackground;
@synthesize minLabel = _minLabel;
@synthesize maxLabel = _maxLabel;

@synthesize labelFormatter = _labelFormatter;

-(Formatter)labelFormatter {
    if(!_labelFormatter) {
        _labelFormatter = ^(double val) {
            return [NSString stringWithFormat:@"%0.2f", val]; };
    }
    return _labelFormatter;
}

- (RangeBar*)initWithFrame:(CGRect)frame minVal:(double)minVal maxVal:(double)maxVal minRange:(double)minRange withValueFormatter:(Formatter)formatter{
    self = [super initWithFrame:frame];
    if (self) {
        self.minimumValue = minVal;
        self.maximumValue = maxVal;
        self.minimumRange = minRange;
        self.labelFormatter = formatter;
        
        double fakeX = 30;
        
        self.selectedMinimumValue = self.minimumValue;
        self.selectedMaximumValue = self.maximumValue;
        
        //track background
        self.trackBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-background.png"]];
        self.trackBackground.frame = CGRectMake((fakeX - self.trackBackground.frame.size.width) / 2, (frame.size.height - self.trackBackground.frame.size.height) / 2, self.trackBackground.frame.size.width, self.trackBackground.frame.size.height);
        [self addSubview:self.trackBackground];
        
        self.padding = (frame.size.height - self.trackBackground.frame.size.height) / 2.0; 
        
        //track
        self.track = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-highlight.png"]];
        self.track.frame = CGRectMake((fakeX - self.track.frame.size.width) / 2, (frame.size.height - self.track.frame.size.height) / 2, self.track.frame.size.width, self.track.frame.size.height);
        [self addSubview:self.track];
        
        //Labels
        self.minLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,35)];
        self.minLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
        self.minLabel.backgroundColor = [UIColor clearColor];
        self.minLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
        self.minLabel.text = @"";
        [self addSubview:self.minLabel];
        self.maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,35)];
        self.maxLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
        self.maxLabel.backgroundColor = [UIColor clearColor];
        self.maxLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
        self.maxLabel.text = @"";
        [self addSubview:self.maxLabel];
        
        //minThumb
        self.minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]];
        
        self.minThumb.frame = CGRectMake(0,0, EFFECTIVE_THUMB_DIAMETER,EFFECTIVE_THUMB_DIAMETER);
        self.minThumb.contentMode = UIViewContentModeCenter;
        self.minThumb.center = CGPointMake(fakeX / 2, [self yForValue:self.selectedMinimumValue]);
        [self addSubview:self.minThumb];
        
        //maxThumb
        self.maxThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]];
        
        self.maxThumb.frame = CGRectMake(0,0, EFFECTIVE_THUMB_DIAMETER,EFFECTIVE_THUMB_DIAMETER);
        self.maxThumb.contentMode = UIViewContentModeCenter;
        self.maxThumb.center = CGPointMake(fakeX / 2, [self yForValue:self.selectedMaximumValue]);
        [self addSubview:self.maxThumb];
        
        [self updateMinLabel];
        [self updateMaxLabel];
    }
    return self;

    
    
}

//I suggest you don't use this one.
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame minVal:0 maxVal:1 minRange:0.01 withValueFormatter:^(double val){return @"";}];
}

-(float) valueForY:(float)y{
    return self.minimumValue + (y-self.padding) / (self.frame.size.height-(self.padding*2)) * (self.maximumValue - self.minimumValue);
}

- (float)yForValue:(float)value {
    float normalizedValue = (value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    float y = (self.frame.size.height - (self.padding * 2)) * normalizedValue + self.padding;
    return y;
}

//for now, don't worry about multiple touches.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch;
    for( UITouch* t in touches) {
        touch = t;
    }
    CGPoint touchPoint = [touch locationInView:self];
    if(CGRectContainsPoint(self.minThumb.frame, touchPoint)){
        _minThumbOn = true;
    }else if(CGRectContainsPoint(self.maxThumb.frame, touchPoint)){
        _maxThumbOn = true;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.minThumbOn = false;
    self.maxThumbOn = false;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.minThumbOn = false;
    self.maxThumbOn = false;
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
        double delVal = [self valueForY:touchPoint.y] - oldVal;
        
        if(delVal >= 0) {
            delVal = delVal + self.minimumRange/2.0 - fmodf(delVal+self.minimumRange/2.0, self.minimumRange); //snap to nearest one
        } else {
            delVal = delVal - self.minimumRange/2.0 - fmodf(delVal-self.minimumRange/2.0, self.minimumRange); 
        }
        
        double newVal = oldVal + delVal;
        
        
        newVal = MAX(newVal, self.minimumValue);
        newVal = MIN(newVal, self.selectedMaximumValue - self.minimumRange);
        
        self.minThumb.center = CGPointMake(self.minThumb.center.x, [self yForValue:newVal]);
        [self updateMinLabel];
        
        self.selectedMinimumValue = newVal;
        [self updateTrackHighlight];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    if(self.maxThumbOn){
        double oldVal = self.selectedMaximumValue;
        double delVal = [self valueForY:touchPoint.y] - oldVal;

        if(delVal >= 0) {
            delVal = delVal + self.minimumRange/2.0 - fmodf(delVal+self.minimumRange/2.0, self.minimumRange); //snap to nearest one
        } else {
            delVal = delVal - self.minimumRange/2.0 - fmodf(delVal-self.minimumRange/2.0, self.minimumRange); 
        }
        
        double newVal = oldVal + delVal;
        newVal = MIN(newVal, self.maximumValue);
        newVal = MAX(newVal, self.selectedMinimumValue + self.minimumRange);
        
        self.maxThumb.center = CGPointMake(self.maxThumb.center.x, [self yForValue:newVal]);
        [self updateMaxLabel];
        self.selectedMaximumValue = newVal;
        [self updateTrackHighlight];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    NSLog(@"diff:%f", [self valueForY:self.maxThumb.center.y]-[self valueForY:self.minThumb.center.y]);
    //NSLog(@"Min: %f, Max: %f", [self valueForY:self.minThumb.center.y], [self valueForY:self.maxThumb.center.y]);
    [self setNeedsDisplay]; 
}

- (void)updateTrackHighlight{
    
    self.track.frame = CGRectMake(self.track.center.x - (self.track.frame.size.width/2),
                                  self.minThumb.center.y,
                                  self.track.frame.size.width,
                                  self.maxThumb.center.y - self.minThumb.center.y);
     
   
}

-(void)updateMinLabel {
    self.minLabel.text = self.labelFormatter(self.selectedMinimumValue);
    self.minLabel.frame = CGRectMake(self.minThumb.center.x + self.minThumb.frame.size.width/2,
                                     self.minThumb.center.y - self.minLabel.frame.size.height/2,
                                     self.minLabel.frame.size.width,
                                     self.minLabel.frame.size.height);
}
    
-(void)updateMaxLabel {
    self.maxLabel.text = self.labelFormatter(self.selectedMaximumValue);
    self.maxLabel.frame = CGRectMake(self.maxThumb.center.x + self.maxThumb.frame.size.width/2,
                                     self.maxThumb.center.y - self.maxLabel.frame.size.height/2,
                                     self.maxLabel.frame.size.width,
                                     self.maxLabel.frame.size.height);
    
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
