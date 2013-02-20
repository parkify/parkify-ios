//
//  IntroAboutPage.m
//  Parkify
//
//  Created by Me on 1/31/13.
//
//

#import "IntroAboutPage.h"
#define IMAGE_DIAMETER 180.0
#define TITLE_HORIZ_PADDING 15
#define IMAGE_TITLE_DIST 15
#define SUBTITLE_HORIZ_PADDING 10
#define TITLE_SUBTITLE_DIST 4

@implementation IntroAboutPage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageName:(NSString*)imageName withTitle:(NSString*)title withSubTitle:(NSString*)subtitle {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGSize imageSize = CGSizeMake(IMAGE_DIAMETER, IMAGE_DIAMETER);
        
        
        UIImage* imgToDisplay = [UIImage imageNamed:imageName];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,imageSize.width, imageSize.height)];
        [imageView setImage:imgToDisplay];
        imageView.layer.cornerRadius = IMAGE_DIAMETER * 0.5;
        imageView.layer.masksToBounds = YES;
        
        UIImageView* circleMask = [[UIImageView alloc] initWithFrame:imageView.frame];
        [circleMask setImage:[UIImage imageNamed:@"circle_bubble_mask.png"]];
        
        [self addSubview:imageView];
        [self addSubview:circleMask];
        
        UIFont* titleFont = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16];
        CGSize titleSize = [title sizeWithFont:titleFont forWidth:frame.size.width-(TITLE_HORIZ_PADDING*2) lineBreakMode:NSLineBreakByWordWrapping];
        
        
        UILabel* titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0,circleMask.frame.origin.y + circleMask.frame.size.height + IMAGE_TITLE_DIST, titleSize.width, titleSize.height)];
        
        [titleLable setTextAlignment:NSTextAlignmentCenter];
        titleLable.text = title;
        titleLable.backgroundColor = [UIColor clearColor];
        titleLable.textColor = [UIColor colorWithWhite:0.92 alpha:1];
        titleLable.font = titleFont;
        
        
        UIFont* subtitleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        CGSize subtitleSize = [@"FILLER" sizeWithFont:subtitleFont forWidth:frame.size.width-(SUBTITLE_HORIZ_PADDING*2) lineBreakMode:NSLineBreakByWordWrapping];
        
        
        UILabel* subtitleLable = [[UILabel alloc] initWithFrame:CGRectMake(0,titleLable.frame.origin.y + titleLable.frame.size.height + TITLE_SUBTITLE_DIST, frame.size.width-(SUBTITLE_HORIZ_PADDING*2), subtitleSize.height*2)];
        subtitleLable.text = subtitle;
        subtitleLable.backgroundColor = [UIColor clearColor];
        subtitleLable.lineBreakMode = NSLineBreakByWordWrapping;
        subtitleLable.numberOfLines = 2;
        subtitleLable.textColor = [UIColor lightTextColor];
        subtitleLable.font = subtitleFont;
        [subtitleLable setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:titleLable];
        [self addSubview:subtitleLable];
        
        /* CENTER ALL THE VIEWS! */
        CGPoint center = imageView.center;
        center.x = self.center.x;
        imageView.center = center;
        
        center = circleMask.center;
        center.x = self.center.x;
        circleMask.center = center;
        
        center = titleLable.center;
        center.x = self.center.x;
        titleLable.center = center;
        
        center = subtitleLable.center;
        center.x = self.center.x;
        subtitleLable.center = center;
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
