//
//  UITabBarController.m
//  Parkify2
//
//  Created by Me on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITabBarController+Hide.h"

@implementation UITabBarController (Hide)
-(void)showTabBar:(BOOL)show {
    UITabBar* tabBar = self.tabBar;
    if (show != tabBar.hidden)
        return;
    UIView* subview = [self.view.subviews objectAtIndex:0];
    CGRect frame = subview.frame;
    frame.size.height += tabBar.frame.size.height * (show ? -1 : 1);
    subview.frame = frame;
    tabBar.hidden = !show;
}
@end