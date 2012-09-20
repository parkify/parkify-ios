//
//  RangeBar.h
//  Parkify2
//
//  Created by Me on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtraTypes.h"

@interface RangeBarVert : UIControl

@property(nonatomic) double minimumValue;
@property(nonatomic) double maximumValue;
@property(nonatomic) double minimumRange;
@property(nonatomic) double selectedMinimumValue;
@property(nonatomic) double selectedMaximumValue;

@property (nonatomic, strong) Formatter labelFormatter;

- (RangeBarVert*)initWithFrame:(CGRect)frame minVal:(double)minVal maxVal:(double)maxVal minRange:(double)minRange withValueFormatter:(Formatter)formatter;

@end