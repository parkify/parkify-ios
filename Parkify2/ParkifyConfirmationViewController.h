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
- (IBAction)closeButtonTapped:(id)sender;
@property (nonatomic, strong) ParkingSpot* spot;
- (IBAction)directionsButtonTapped:(UIButton *)sender;

@property double currentLat;
@property double currentLong;

@property (weak, nonatomic) IBOutlet UITextView *infoBox;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;


@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property double startTime;
@property double endTime;
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;
@property (weak, nonatomic) IBOutlet UIWebView *bottomWebView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIWebView *topWebView;
@property (weak, nonatomic) IBOutlet UIScrollView *topScrollView;

@end
