//
//  RangeBar.h
//  Parkify2
//
//  Created by Me on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtraTypes.h"

@interface RangeBar : UIControl

@property(nonatomic) double minimumValue;
@property(nonatomic) double maximumValue;
@property(nonatomic) double minimumRange;
@property(nonatomic) double displayedRange;
@property(nonatomic) double selectedMinimumValue;
@property(nonatomic) double selectedMaximumValue;

@property (nonatomic, strong) Formatter labelFormatter;

- (RangeBar*)initWithFrame:(CGRect)frame minVal:(double)minVal maxVal:(double)maxVal minRange:(double)minRange displayedRange:(double)displayedRange selectedMinVal:(double)selectedMinVal selectedMaxVal:(double)selectedMaxVal withValueFormatter:(Formatter)formatter;

@end
