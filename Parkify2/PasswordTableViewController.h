//
//  PasswordTableViewController.h
//  Parkify
//
//  Created by Me on 10/29/12.
//
//

#import <UIKit/UIKit.h>

#import "ParkifyTableViewController.h"

@interface PasswordTableViewController : ParkifyTableViewController

@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* passwordConf;
@property (strong, nonatomic) NSString* origPassword;

@end
