//
//  ParkifyConfirmationViewController.h
//  Parkify2
//
//  Created by Me on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkingSpot.h"

@interface ParkifyConfirmationViewController : UIViewController <UIScrollViewDelegate, UIWebViewDelegate, UIAlertViewDelegate   >
- (IBAction)closeButtonTapped:(id)sender;
@property (nonatomic, strong) ParkingSpot* spot;
- (IBAction)directionsButtonTapped:(UIButton *)sender;

@property double currentLat;
@property double currentLong;

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property double startTime;
@property double endTime;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) NSString* topBarText;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UILabel *topViewLabel;

- (IBAction)launchTroubleAlert:(id)sender;

//TODO: REMOVETHIS
@property (weak, nonatomic) IBOutlet UIButton *topBarTapped;

- (IBAction)topBarButtonTapped:(id)sender;
@end
