//
//  ParkifyAbioutControllerViewController.h
//  Parkify
//
//  Created by Me on 8/24/12.
//
//

#import <UIKit/UIKit.h>

@interface ParkifyAboutViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *viewWeb;
- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender;

@end
