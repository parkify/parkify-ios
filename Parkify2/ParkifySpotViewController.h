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
#import "FlatRateBar.h"
#import "ASIHTTPRequest.h"
@interface ParkifySpotViewController : UIViewController <ParkingSpotObserver, UIAlertViewDelegate, ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet UILabel *flashingSign;
@property (weak, nonatomic) IBOutlet UIView *demoMask;

@property (strong, nonatomic) ParkingSpot* spot;

@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property double currentLat;
@property double currentLong;
@property (weak, nonatomic) IBOutlet UIButton *timeTypeSelectHourlyButton;
@property (weak, nonatomic) IBOutlet UIButton *timeTypeSelectFlatRateButton;
- (IBAction)timeTypeSelectButtonTapped:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIWebView *infoWebView;
@property (weak, nonatomic) IBOutlet UILabel *timeDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDurationHourStaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDurationMinutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDurationMinutesStaticLabel;

@property (weak, nonatomic) IBOutlet UIView *flatRateBarContainer;
@property (strong, nonatomic) FlatRateBar* flatRateBar;



@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceCurrencyLabel;
@property (weak, nonatomic) IBOutlet UIView *rangeBarContainer;
- (IBAction)parkButtonTapped:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *startTimeALabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeALabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (strong, nonatomic) NSTimer *timerPolling;
@property (strong, nonatomic) NSString* distanceString;
@property double timerDuration;
@property (strong, nonatomic) RangeBar* rangeBar; 
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

- (IBAction)closeButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;

//@property double startTime;
//@property double endTime;
@property (weak, nonatomic) IBOutlet UIView *multiImageViewFrame;
@property (weak, nonatomic) IBOutlet UIImageView *timeCenterReference;
@property (weak, nonatomic) IBOutlet UIImageView *durationCenterReference;
@property (weak, nonatomic) IBOutlet UIImageView *priceCenterReference;

@end
