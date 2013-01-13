//
//  troubleFindingSpotViewController.h
//  Parkify
//
//  Created by gnamit on 11/8/12.
//
//

#import <UIKit/UIKit.h>
#import "ParkingSpot.h"
#import "ASIHTTPRequest.h"
#import "Acceptance.h"
@interface troubleFindingSpotViewController : UIViewController<UIAlertViewDelegate, ASIHTTPRequestDelegate>
{
    
}
@property (nonatomic, strong)Acceptance *transactionInfo;
@property(nonatomic, strong)ParkingSpot *theSpot;

- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)refundAndReturn:(id)sender;
- (IBAction)launchPhone:(id)sender;
- (IBAction)launchDirections:(id)sender;
@end
