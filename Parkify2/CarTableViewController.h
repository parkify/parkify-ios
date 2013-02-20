//
//  CarTableViewController.h
//  Parkify
//
//  Created by Me on 10/26/12.
//
//

#import <UIKit/UIKit.h>
#import "Car.h"

#import "ParkifyTableViewController.h"

@interface CarTableViewController : ParkifyTableViewController

@property (strong, nonatomic) Car* car;
@end
