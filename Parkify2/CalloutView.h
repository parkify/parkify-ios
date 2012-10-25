//
//  CalloutView.h
//  Parkify
//
//  Created by Me on 10/17/12.
//
//

#import <UIKit/UIKit.h>

@interface CalloutView : UIControl

@property (strong, nonatomic) UIView* innerView;
@property (strong, nonatomic) UIImageView* backgroundImageView;
@property (strong, nonatomic) UIImageView* arrowImageView;
@property double radius;
@property double xOffset;


- (id)initWithFrame:(CGRect)frame withXOffset:(double)xOffset withCornerRadius:(double)radius withInnerView:(UIView*) innerView;

+ (CGRect)frameThatFits:(UIView*)view withCornerRadius:(double)radius;
- (CGRect)frameThatFits;
@end
