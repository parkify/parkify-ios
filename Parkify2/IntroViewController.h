//
//  IntoViewController.h
//  Parkify
//
//  Created by Me on 1/31/13.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "ASIHTTPRequest.h"


@interface IntroViewController : UIViewController <UIScrollViewDelegate, ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *keyboardAvoidingScrollView;
@property BOOL openedFromSettings;
@end
