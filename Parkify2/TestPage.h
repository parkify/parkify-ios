//
//  ErrorPage.h
//  Parkify
//
//  Created by Me on 1/24/13.
//
//

#import <UIKit/UIKit.h>
#import "DirectionsFlowing.h"

@interface TestPage : UIControl <DirectionsFlowing>

- (void)moreToLeft:(BOOL)isMore;
- (void)moreToRight:(BOOL)isMore;

@property (strong, nonatomic) UILabel* label;

@end
