//
//  mapDirectionsViewController.h
//  Parkify
//
//  Created by gnamit on 11/12/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ParkingSpot.h"
#import "Acceptance.h"

#import "MyWebView.h"
@interface mapDirectionsViewController : UIViewController <webViewCustomDelegate, UIWebViewDelegate,CLLocationManagerDelegate, UITabBarDelegate>
{
    int spotId;
    UIWebView *currWebView;
    BOOL textDirs;
}
@property (weak, nonatomic) IBOutlet UITabBar *flowTabBar;

@property (nonatomic, strong) Acceptance* reservation;
@property (nonatomic, strong) ParkingSpot* spot;
@property BOOL showTopBar;

@end
