//
//  CalloutView.m
//  Parkify
//
//  Created by Me on 10/17/12.
//
//

#import "CalloutView.h"
#import <QuartzCore/QuartzCore.h>

@interface CalloutView ()
@property (strong, nonatomic) UIView* backgroundContainer;
@end

@implementation CalloutView

@synthesize innerView = _innerView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize arrowImageView = _arrowImageView;
@synthesize backgroundContainer = _backgroundContainer;

@synthesize radius = _radius;
@synthesize xOffset = _xOffset;

#define ARROW_WIDTH 16
#define ARROW_HEIGHT 10

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self adjustSubviews];
}

//I suggest you don't use this one.
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withXOffset:frame.size.width/2 withCornerRadius:15 withInnerView:[[UIView alloc] initWithFrame:frame]];
}

- (id)initWithFrame:(CGRect)frame withXOffset:(double)xOffset withCornerRadius:(double)radius withInnerView:(UIView*) innerView
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.xOffset = xOffset;
        self.radius = radius;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        
        //Callout Arrow
        //float y = frame.origin.y + frame.size.height - ARROW_HEIGHT;
        
        
        UIImage* arrowImg = [UIImage imageNamed:@"white_callout_arrow.png"];
        
        self.arrowImageView = [[UIImageView alloc] init];
        self.arrowImageView.image = arrowImg;
        
        [self addSubview:self.arrowImageView];
        
        
        //Callout Body
        
        UIImage* bodyImg = [UIImage imageNamed:@"white_callout_background.png"];
        
        self.backgroundContainer = [[UIView alloc] init];
        [self.backgroundContainer.layer setCornerRadius:radius];
        [self.backgroundContainer setClipsToBounds:true];
        [self addSubview:self.backgroundContainer];
        
        self.backgroundImageView = [[UIImageView alloc] init];
        self.backgroundImageView.image = bodyImg;
        
        [self.backgroundContainer addSubview:self.backgroundImageView];
       
        
        //Main inner view
        if(innerView) {
            [self addSubview:self.innerView];
            self.innerView = innerView;
        }
        [self adjustSubviews];
    }
    
    return self;
}

-(void)adjustSubviews {
    
    float y = self.frame.size.height - ARROW_HEIGHT;
    CGRect arrowFrame = CGRectMake(self.xOffset - (ARROW_WIDTH/2.0),y,ARROW_WIDTH,ARROW_HEIGHT);
    
    self.arrowImageView.frame = arrowFrame;
    
    float height = self.frame.size.height - ARROW_HEIGHT;
    
    CGRect bodyContainerFrame = CGRectMake(0,0,self.frame.size.width,height);
    CGRect bodyFrame = CGRectMake(0,0,self.frame.size.width,height);
    self.backgroundContainer.frame = bodyContainerFrame;
    self.backgroundImageView.frame = bodyFrame;
    
    if(self.innerView) {
        if(![self.subviews containsObject:self.innerView]) {
            [self addSubview:self.innerView];
        }
        CGRect innerFrame = CGRectMake(bodyFrame.origin.x + self.radius,
                                       bodyFrame.origin.y + self.radius,
                                       bodyFrame.size.width - 2*self.radius,
                                       bodyFrame.size.height - 2*self.radius);
        
        self.innerView.frame = innerFrame;
    }
}


+ (CGRect)frameThatFits:(UIView*)view withCornerRadius:(double)radius {
    return CGRectMake(view.frame.origin.x,
                      view.frame.origin.y,
                      view.frame.size.width + 2*radius,
                      view.frame.size.height + 2*radius + ARROW_HEIGHT);
}
- (CGRect)frameThatFits {
    return [CalloutView frameThatFits:self.innerView withCornerRadius:self.radius];
    
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
