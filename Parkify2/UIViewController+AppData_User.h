//
//  UIViewController+AppData_User.h
//  Parkify
//
//  Created by Me on 11/3/12.
//
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UIViewController (AppData_User)

- (User*)getUser;

@end

@interface UIView (AppData_User)

- (User*)getUser;

@end
