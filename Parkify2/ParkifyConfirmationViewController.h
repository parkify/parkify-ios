//
//  ParkifyConfirmationViewController.h
//  Parkify2
//
//  Created by Me on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkingSpot.h"
#import "Acceptance.h"  
@interface ParkifyConfirmationViewController : UIViewController <UIScrollViewDelegate, UIWebViewDelegate, UIAlertViewDelegate   >



- (IBAction)closeButtonTapped:(id)sender;
@property (nonatomic, strong) ParkingSpot* spot;
- (IBAction)directionsButtonTapped:(UIButton *)sender;

@property double currentLat;
@property double currentLong;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
//@property double startTime;
//@property double endTime;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) UIButton* extendButton;

@property (strong, nonatomic) NSString* topBarText;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UILabel *topViewLabel;
@property (nonatomic, weak) Acceptance *transactionInfo;
- (IBAction)launchTroubleAlert:(id)sender;

//TODO: REMOVETHIS
@property (weak, nonatomic) IBOutlet UIButton *topBarTapped;
- (IBAction)extendReservation:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *scrollIndicator;

- (IBAction)topBarButtonTapped:(id)sender;



@end
