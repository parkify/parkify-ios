//
//  ConfirmationPage.h
//  Parkify
//
//  Created by Me on 1/23/13.
//
//

#import <UIKit/UIKit.h>
#import "ParkingSpot.h"
#import "Acceptance.h"
#import "DirectionsFlowing.h"

@interface ConfirmationPage : UIControl<UIScrollViewDelegate, UIWebViewDelegate, UIAlertViewDelegate, DirectionsFlowing >
@property (nonatomic, strong) ParkingSpot* spot;
@property (nonatomic, weak) Acceptance *reservation;

@property (weak, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIButton* extendButton;

@property (strong, nonatomic) NSString* topBarText;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UILabel *topViewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *scrollIndicator;

- (id)initWithFrame:(CGRect)frame withSpot:(ParkingSpot*)spot withReservation:(Acceptance*)reservation;

-(void)moreToRight:(BOOL)isMore;
-(void)moreToLeft:(BOOL)isMore;



@end
