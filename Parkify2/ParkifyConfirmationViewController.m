//
//  ParkifyConfirmationViewController.m
//  Parkify2
//
//  Created by Me on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkifyConfirmationViewController.h"
#import <QuartzCore/QuartzCore.h> 
#import "ExtraTypes.h"
#import "TextFormatter.h"

@interface ParkifyConfirmationViewController ()

@end

@implementation ParkifyConfirmationViewController

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

@synthesize titleLable = _titleLable;
@synthesize spot = _spot;
@synthesize infoBox = _infoBox;
@synthesize timeLabel = _timeLabel;
@synthesize priceLabel = _priceLabel;

@synthesize errorLabel = _errorLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self updateInfo];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)updateInfo {
    //Info box
    NSString* infoTitle;
    NSString* infoBody;
    NSString* timeString;
    NSString* priceString;
    
    if(self.spot == nil) {
        infoTitle = @"Spot not found";
        infoBody = @"";
        timeString = @"";
        priceString = @"";
        
    }
    else {
        infoTitle = [NSString stringWithFormat:@"%@ Spot #%d", 
                     self.spot.mCompanyName, self.spot.mLocalID];
        infoBody = self.spot.mDesc; 
        
        //Time text
        Formatter formatter = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            return [dateFormatter stringFromDate:time]; };
        
        timeString = [NSString stringWithFormat:@"Time Booked: %@ - %@", formatter(self.startTime), formatter(self.endTime)];
        
        //Price text
        double durationInHours = (self.endTime - self.startTime)/3600;
        double totalPrice = self.spot.mPrice * durationInHours;
        priceString = [NSString stringWithFormat:@"$%0.2f Charged to ************4242", totalPrice];
        
    }
    CGAffineTransform squish = [TextFormatter transformForSpotViewText];
    self.titleLable.text = infoTitle;
    [self.infoBox setText:infoBody];
    self.timeLabel.text = timeString;
    self.timeLabel.transform = squish;
    self.priceLabel.text = priceString;
    self.priceLabel.transform = squish;
    
}




- (IBAction)closeButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
}
@end
