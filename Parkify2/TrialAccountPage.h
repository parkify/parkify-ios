//
//  DarkTextCell.h
//  Parkify
//
//  Created by Me on 2/1/13.
//
//

#import <UIKit/UIKit.h>
#import "DirectionsFlowing.h"
#import "TPKeyboardAvoidingScrollView.h"


@interface TrialAccountPage : UIControl <DirectionsFlowing, UITextFieldDelegate>
- (void) moreToLeft:(BOOL)isMore;
- (void) moreToRight:(BOOL)isMore;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *keyboardAvoidingScrollView;

- (void) setStateTrialAccount;
- (void) setStateWaiting;
- (void) setStatePassThrough;

@end
