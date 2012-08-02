//
//  ParkifyConfirmationViewController.h
//  Parkify2
//
//  Created by Me on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkingSpot.h"

@interface ParkifyConfirmationViewController : UIViewController
- (IBAction)closeButtonTapped:(UIButton *)sender;
@property (nonatomic, strong) ParkingSpot* spot;


@property (weak, nonatomic) IBOutlet UITextView *infoBox;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;


@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property double startTime;
@property double endTime;

@end
