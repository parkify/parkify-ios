//
//  ParkifySpotViewController.h
//  Parkify2
//
//  Created by Me on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkingSpot.h"
#import "ParkingSpotCollection.h"
#import "RangeBar.h"

@interface ParkifySpotViewController : UIViewController <ParkingSpotObserver, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *flashingSign;

@property (nonatomic, strong) ParkingSpotCollection* parkingSpots;

@property (strong, nonatomic) ParkingSpot* spot;

@property double currentLat;
@property double currentLong;

@property (weak, nonatomic) IBOutlet UIScrollView *infoScrollView;
@property (weak, nonatomic) IBOutlet UIWebView *infoWebView;
@property (weak, nonatomic) IBOutlet UILabel *timeDurationLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoBox;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIView *rangeBarContainer;
- (IBAction)parkButtonTapped:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) NSTimer *timerPolling;
@property (strong, nonatomic) NSString* distanceString;
@property double timerDuration;
@property (strong, nonatomic) RangeBar* rangeBar; //maybe should be weak?
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

- (IBAction)closeButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

//@property double startTime;
//@property double endTime;

@end
