//
//  CreditCardTableViewController.h
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import <UIKit/UIKit.h>
#import "CreditCard.h"
#import "ParkifyTableViewController.h"

@interface CreditCardTableViewController : ParkifyTableViewController
@property (strong, nonatomic) CreditCard* creditCardModel;


@end
