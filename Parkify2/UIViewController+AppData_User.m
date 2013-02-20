//
//  UIViewController+AppData.m
//  Parkify
//
//  Created by Me on 11/3/12.
//
//

#import "UIViewController+AppData_User.h"
#import "ParkifyAppDelegate.h"

@implementation UIViewController (AppData_User)

- (User*)getUser {
  return ((ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate]).user;
}



@end


@implementation UIView (AppData_User)

- (User*)getUser {
    return ((ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate]).user;
}



@end
