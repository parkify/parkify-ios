//
//  AccountUpdatePage.h
//  Parkify
//
//  Created by Me on 2/7/13.
//
//

#import <UIKit/UIKit.h>
#import "DirectionsFlowing.h"
#import "ParkingSpot.h"
#import "ELCTextfieldCell.h"
#import "Car.h"
#import "User.h"
#import "CreditCard.h"

@interface AccountUpdatePage : UIControl <DirectionsFlowing, ELCTextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>
- (void)moreToLeft:(BOOL)isMore;
- (void)moreToRight:(BOOL)isMore;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)onLocationSelection;
- (id)initWithFrame:(CGRect)frame withUpdateType:(NSString*)updateType withUser:(User*)user;

@property (strong, nonatomic) User* user;
@property (strong, nonatomic) Car* car;
@property (strong, nonatomic) CreditCard* card;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@end
