//
//  ParkifySpotViewController.m
//  Parkify2
//
//  Created by Me on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkifySpotViewController.h"

@interface ParkifySpotViewController ()

@end

@implementation ParkifySpotViewController

@synthesize parkingSpots = _parkingSpots;
@synthesize spot = _spot;
@synthesize infoBox = _infoBox;
@synthesize timeLabel = _timeLabel;
@synthesize priceLabel = _priceLabel;
@synthesize rangeBarContainer = _rangeBarContainer;

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

@synthesize timerPolling = _timerPolling;
@synthesize timerDuration = _timerDuration;

@synthesize rangeBar = _rangeBar;

- (void)startTime:(double)time {
    _startTime = time;
    [self updateInfo];
}
- (void)endTime:(double)time {
    _endTime = time;
    [self updateInfo];
}

- (ParkingSpotCollection*)parkingSpots {
    if(!_parkingSpots) {
        _parkingSpots = [[ParkingSpotCollection alloc] init];
        _parkingSpots.observerDelegate = self;
    }
    return _parkingSpots;
}

- (void)setSpot:(ParkingSpot*)parkingSpot {
    _spot = parkingSpot;
    [self updateInfo];
}

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
    /*
    RangeSlider *slider = [[RangeSlider alloc] initWithFrame:CGRectMake(0,0,100,20)];
    slider.minimumValue = 1;
    slider.selectedMinimumValue = 2;
    slider.maximumValue = 10;
    slider.selectedMaximumValue = 8;
    slider.minimumRange = 2;
    [slider addTarget:self action:@selector(updateRangeLabel:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:slider];
     */
    
    //It's time to duel!
    NSDate* currentDate = [NSDate date];
    
    double currentTime = [currentDate timeIntervalSince1970];
    
    currentTime = currentTime - fmod(currentTime,1800); 
    
    Formatter formatter = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        return [dateFormatter stringFromDate:time]; };
    
    self.rangeBar = [[RangeBar alloc] initWithFrame:[self.rangeBarContainer bounds] minVal:currentTime maxVal:currentTime + 6*30*60 minRange:30*60 withValueFormatter:formatter];    
    //^(double val){return [@"Foo";}
    
    [self.rangeBar addTarget:self action:@selector(timeIntervalChanged) forControlEvents:UIControlEventValueChanged];
    [self.rangeBarContainer addSubview:self.rangeBar];
    
    [self updateInfo];
    
    self.timerDuration = 5;
    [self startPolling];
}

- (void)timeIntervalChanged{
    [self updateInfo];
}

- (void)viewDidUnload
{
    [self setInfoBox:nil];
    [self setTimeLabel:nil];
    [self setPriceLabel:nil];
    [self setRangeBarContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)spotsWereUpdated {
    self.spot = [self.parkingSpots parkingSpotForID:self.spot.mID];
}
/*
 - (NSString *)title {
 return [NSString stringWithFormat:@"%@ %d | %0.2f/hr", 
 self.spot.mCompanyName, self.spot.mLocalID, self.spot.mPrice];
 }
 - (NSString *)subtitle {
 return [NSString stringWithFormat:@"%@ to Book", self.spot.mPhoneNumber];
 }
 */

-(void)updateInfo {
    //Info box
    NSString* infoHeader;
    if(self.spot == nil) {
        infoHeader = @"Spot not found";
    }
    infoHeader = [NSString stringWithFormat:@"%@ Spot #%d | Price: %0.2f/hr\nCALL %@ to Book Now!", 
                            self.spot.mCompanyName, self.spot.mLocalID, self.spot.mPrice, self.spot.mPhoneNumber];
    [self.infoBox setText:infoHeader];
    
    //Time text
    Formatter formatter = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        return [dateFormatter stringFromDate:time]; };
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%@ - %@", formatter(self.rangeBar.selectedMinimumValue), formatter(self.rangeBar.selectedMaximumValue)]];
    
    //Price text
    double durationInHours = (self.rangeBar.selectedMaximumValue - self.rangeBar.selectedMinimumValue)/3600;
    double totalPrice = self.spot.mPrice * durationInHours;
    [self.priceLabel setText:[NSString stringWithFormat:@"Total Price: $%0.2f", totalPrice]];
    
}

- (IBAction)parkButtonTapped:(UIButton *)sender {
}



//Starts polling if not already. Otherwise continues polling.
-(void)startPolling {
    if (self.timerPolling != nil)
    {
        return;
    } else {
        self.timerPolling = [NSTimer scheduledTimerWithTimeInterval: self.timerDuration
                                                         target: self
                                                       selector:@selector(onTick:)
                                                       userInfo: nil repeats:NO];
    }
}

-(void)stopPolling {
    if (self.timerPolling == nil)
    {
        return;
    } else {
        [self.timerPolling invalidate];
        self.timerPolling = nil;
    }
}

-(void)onTick:(NSTimer *)timer {
//do smth

    [self refreshSpots];

    self.timerPolling = [NSTimer scheduledTimerWithTimeInterval: self.timerDuration
                                                     target: self
                                                   selector:@selector(onTick:)
                                                   userInfo: nil repeats:NO];
}

- (void)refreshSpots
{
    [self.parkingSpots updateWithRequest:nil];
}

@end