//
//  FlatRateBar.h
//  Parkify
//
//  Created by Me on 1/3/13.
//
//

#import <UIKit/UIKit.h>

@interface FlatRateBar : UIControl

@property (nonatomic, strong) NSMutableDictionary* flatPrices;
@property (nonatomic, strong) NSMutableArray* flatRateBubbles;
@property (nonatomic, strong) NSMutableArray* flatRateSubLabels;

- (void)positionBubbles;

- (id)initWithFrame:(CGRect)frame withPrices:(NSMutableDictionary*)flatPricesIn;

- (IBAction)bubbleWasTapped:(id)sender;

- (double)selectedDuration;

@end
