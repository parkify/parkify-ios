//
//  DrivingDirectionsPage.h
//  Parkify
//
//  Created by Me on 1/25/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyWebView.h"
#import "DirectionsFlowing.h"

#import "ParkingSpot.h"
#import "Acceptance.h"

@interface DrivingDirectionsPage : UIControl <webViewCustomDelegate, UIWebViewDelegate, DirectionsFlowing> {
    double spotLat;
    double spotLong;
    int spotId;
    UIWebView *currWebView;
    BOOL textDirs;
}
- (id)initWithFrame:(CGRect)frame withSpot:(ParkingSpot*)spot withReservation:(Acceptance*)reservation;

@property (nonatomic, strong) Acceptance* reservation;
@property (nonatomic, strong) ParkingSpot* spot;


-(void)moreToRight:(BOOL)isMore;
-(void)moreToLeft:(BOOL)isMore;

@end
