//
//  RangeBubble.h
//  Parkify
//
//  Created by Me on 10/9/12.
//
//

#import <UIKit/UIKit.h>
#import "ExtraTypes.h"

@interface RangeBubble : UIControl

@property(nonatomic) double minimumValue;
@property(nonatomic) double maximumValue;
@property(nonatomic) double minimumRange;
@property(nonatomic) double selectedMinimumValue;
@property(nonatomic) double selectedMaximumValue;

@property (nonatomic, strong) Formatter timeFormatter;
@property (nonatomic, strong) Formatter priceFormatter;


- (RangeBubble*)initWithFrame:(CGRect)frame minVal:(double)minVal maxVal:(double)maxVal minRange:(double)minRange selectedMinVal:(double)selectedMinVal selectedMaxVal:(double)selectedMaxVal withPriceFormatter:(Formatter)priceFormatter withTimeFormatter:(Formatter)timeFormatter;

@end
