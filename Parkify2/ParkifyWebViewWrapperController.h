//
//  ParkifyWebViewWrapperController.h
//  Parkify
//
//  Created by Me on 9/9/12.
//
//

#import <UIKit/UIKit.h>

@interface ParkifyWebViewWrapperController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *viewWeb;
- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender;

@property (strong, nonatomic) NSString* url;
- (IBAction)callParkify:(UIButton *)sender;
@end
