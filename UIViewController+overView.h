//
//  UIViewController+overView.h
//  Created by Kevin Lohman on 5/30/12.
//

#import <UIKit/UIKit.h>

@interface UIViewController (OverView)
- (void)presentOverViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissOverViewControllerAnimated:(BOOL)animated;
@end