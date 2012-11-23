//
//  extendReservationViewController.m
//  Parkify
//
//  Created by gnamit on 11/19/12.
//
//

#import "extendReservationViewController.h"
#import "Persistance.h"
#import "MultiImageViewer.h"
#import "UIViewController+AppData_ParkingSpotCollection.h"
#import "TextFormatter.h"

@interface extendReservationViewController ()

@end

@implementation extendReservationViewController
@synthesize transactioninfo= _transactioninfo;
@synthesize taxLabel = _taxLabel;
//@synthesize pictureActivityView = _pictureActivityView;
//@synthesize imageView = _imageView;
@synthesize titleLable = _titleLable;

@synthesize flashingSign = _flashingSign;
@synthesize spot = _spot;
//@synthesize infoScrollView = _infoScrollView;
@synthesize infoWebView = _infoWebView;
@synthesize timeDurationLabel = _timeDurationLabel;
//@synthesize infoBox = _infoBox;
//@synthesize timeLabel = _timeLabel;
@synthesize priceLabel = _priceLabel;
@synthesize rangeBarContainer = _rangeBarContainer;

@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;

@synthesize distanceString = _distanceString;

//@synthesize startTime = _startTime;
//@synthesize endTime = _endTime;

//@synthesize errorLabel = _errorLabel;
@synthesize timerPolling = _timerPolling;
@synthesize timerDuration = _timerDuration;

@synthesize rangeBar = _rangeBar;

-(void)fillInfoWebView {
    NSString* infoWebViewString;
    /*
     NSString* styleString = @"<style type=\"text/css\">"
     //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
     ".top { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:14; color:black}"
     ".top-mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#224455;}"
     ".mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#556677;}"
     ".bottom { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:16; color:black; }"
     ".selected { color:#224455; } "
     ".faded { color:#99AABB; }"
     ".fake-space {font-size:5;}"
     "</style>";
     */
    NSString* styleString = @"<style type=\"text/css\">"
    //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
    ".l1 { background-color:transparent; font-family:\"HelveticaNeue-Bold\"; font-size:12; color:white}"
    ".l2 { background-color:transparent; font-family:\"HelveticaNeue-Bold\"; font-size:30; color:white;}"
    ".l3 { background-color:transparent; font-family:\"HelveticaNeue-Bold\"; font-size:12; color:white;}"
    ".l4 { background-color:transparent; font-family:\"HelveticaNeue-Bold\"; font-size:12; color:white; }"
    ".selected { color:white; } "
    ".faded { color:white; }"
    ".fake-space {font-size:5;}"
    "</style>";
    if(self.spot == nil) {
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>Spot Not Available.</body></html>", styleString];
    }
    else {
        
        NSString* layoutString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"parallel"]) {
            layoutString = @"<span class=faded>YES</span>";
        } else {
            layoutString = @"<span class=selected>NO</span>";
        }
        
        NSString* coverageString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"covered"]) {
            coverageString = @"<span class=faded>YES</span>"    ;
        } else {
            coverageString = @"<span class=selected>NO</span>";
        }
        
        
        /*[NSString stringWithFormat:@"<html>%@<body>"
         "<span class=l1>Distance away</span></br>"
         "<span class=l2>%@</span></br>"
         "<span class=l3>%@</span></br>"
         "<span class=fake-space></br></span>"
         "<span class=fake-space></br></span>"
         "<span class=l4>PARALLEL: %@</span></br>"
         "<span class=l4>COVERED: %@</span></br>"
         "<span class=fake-space></br></span>"
         "<span class=bottom>Current Rate: $%0.2f/hr</span><hr/>"
         "<span class=top>%@</span><hr/></p>"
         "</body></html>",
         styleString,
         self.distanceString,
         self.spot.mAddress,
         layoutString,
         coverageString,
         [self.spot currentPrice],
         self.spot.mDesc];*/
        
        //Info web view text
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>"
                             "<span class=l1>Distance away</span></br>"
                             "<span class=l2>%@</span></br>"
                             "<span class=l3>%@</span></br>"
                             "<span class=fake-space></br></span>"
                             "<span class=fake-space></br></span>"
                             "<span class=l4>PARALLEL: %@</span></br>"
                             "<span class=l4>COVERED: %@</span>"
                             "</body></html>",
                             styleString,
                             self.distanceString,
                             [TextFormatter formatSecuredAddressString:self.spot.mAddress],
                             layoutString,
                             coverageString,
                             [self.spot currentPrice],
                             self.spot.mDesc];
    }
    [self.infoWebView loadHTMLString:infoWebViewString baseURL:nil];
    
    CGRect frame = self.infoWebView.frame;
    frame.size.height = 1;
    self.infoWebView.frame = frame;
    CGSize fittingSize = [self.infoWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    self.infoWebView.frame = frame;
    //   self.infoScrollView.contentSize = frame.size;
    
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
    self.title = @"Extend reservation";
    NSDate* currentDate = [NSDate date];
    NSString *lastPayment = [Persistance retrieveLastPaymentInfoDetails];
    NSLog(@"Last payment %@", lastPayment);
    double currentTime = [currentDate timeIntervalSince1970];
    MultiImageViewer* miViewer = [[MultiImageViewer alloc] initWithFrame:self.multiImageViewFrame.frame withImageIds:self.spot.landscapeInfoImageIDs];
    
    CGRect frame = miViewer.frame;
    frame.origin = CGPointMake(0,0);
    miViewer.frame = frame;
    [self.multiImageViewFrame addSubview:miViewer];
    
    //currentTime = currentTime - fmod(currentTime,1800);
    
    double timeLeft = [self.spot endTime] - currentTime;
    
    double numHours = 9;
    
    timeLeft = timeLeft - fmod(timeLeft,1800);
    timeLeft = MIN(timeLeft, numHours*60*60);
    
    
    double prevHourMark = (floor(currentTime/3600))*3600;
    
    Formatter timeFormatter = ^(double val) {
        NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ha"];
        return [dateFormatter stringFromDate:time]; };
    
    
    self.spot = [[self getParkingSpots] parkingSpotForIDFromAll:[[self.transactioninfo objectForKey:@"spotid"] intValue]];
    //[[self.transactioninfo objectForKey:@"endtime"] doubleValue]
    double maxVal = self.spot.endTime;
   // maxVal = [[self.transactioninfo objectForKey:@"endtime"] doubleValue];
    self.rangeBar = [[RangeBar alloc] initWithFrame:[self.rangeBarContainer bounds] minVal:prevHourMark minimumSelectableValue:[[self.transactioninfo objectForKey:@"endtime"] doubleValue]-(30*60) maxVal:maxVal minRange:30*60 displayedRange:numHours*60*60 selectedMinVal:currentTime selectedMaxVal:[[self.transactioninfo objectForKey:@"endtime"] doubleValue] withTimeFormatter:timeFormatter withPriceFormatter:^NSString *(double val) {
        if(fmod(val,1.0) >= 0.01) {
            return [NSString stringWithFormat:@"$%0.2f", val];
        } else {
            return [NSString stringWithFormat:@"$%0.0f", val];
        }
    } withPriceSource:self.spot];
    
    
    //^(double val){return [@"Foo";}
    
    
    
  //  [self.rangeBar addTarget:self action:@selector(timeIntervalChanged) forControlEvents:UIControlEventValueChanged];
    [self.rangeBarContainer addSubview:self.rangeBar];
    [self.view bringSubviewToFront:self.rangeBarContainer];
    [self updateInfo];
    
    [self fillInfoWebView];
    
    self.timerDuration = 20;
    [self startPolling];

	// Do any additional setup after loading the view.
}
-(void)updateInfo {
    //Info box
    NSString* infoTitle;
    NSString* infoBody;
    NSString* timeString;
    NSString* priceString;
    NSString* timeDurationString;
    NSString* startTime;
    NSString* endTime;
    NSString* startTimeA;
    NSString* endTimeA;
    
    
    if(self.spot == nil) {
        infoTitle = @"Spot not found";
        infoBody = @"";
        timeString = @"";
        priceString = @"";
        timeDurationString = @"";
        startTime = @"";
        endTime = @"";
    }
    else {
        infoTitle = [NSString stringWithFormat:@"Parkify Spot"];
        infoBody = self.spot.mDesc;
        
        //Time text
        Formatter formatterMain = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm"];
            return [dateFormatter stringFromDate:time]; };
        
        Formatter formatterA = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"a"];
            return [dateFormatter stringFromDate:time]; };
        
        
        
        startTime = formatterMain(self.rangeBar.selectedMinimumValue);
        startTimeA = formatterA(self.rangeBar.selectedMinimumValue);
        endTime = formatterMain(self.rangeBar.selectedMaximumValue);
        endTimeA = formatterA(self.rangeBar.selectedMaximumValue);
        
        //Price text
        double durationInSeconds = (self.rangeBar.selectedMaximumValue - self.rangeBar.selectedMinimumValue);
        ParkingSpot* spot = self.spot;
        double totalPrice = [spot priceFromNowForDurationInSeconds:durationInSeconds];
        
        priceString = [NSString stringWithFormat:@"$%0.2f", totalPrice];
        
        //TimeDuration text
        double hoursAndMinutes = round(durationInSeconds/60)/60;
        int hours = floor(hoursAndMinutes);
        int minutes = floor((hoursAndMinutes-hours)*60);
        
        
        timeDurationString = [NSString stringWithFormat:@"%dh%@%d", hours, (minutes<=9) ? @"0" : @"", minutes ];
        
    }
    
    CGAffineTransform squish = [TextFormatter transformForSpotViewText];
    //self.taxLabel.transform = squish;
    self.titleLable.text = infoTitle;
    [self setTitle:infoTitle];
    // self.timeLabel.text = timeString;
    //self.timeLabel.transform = squish;
    self.priceLabel.text = priceString;
    //self.priceLabel.transform = squish;
    self.timeDurationLabel.text = timeDurationString;
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@%@",startTime,startTimeA];
    self.endTimeALabel.text = endTimeA;
    self.endTimeLabel.text = endTime;
    
    CGRect frame = self.endTimeALabel.frame;
    CGSize size = [endTime sizeWithFont:self.endTimeLabel.font];
    frame.origin.x = self.endTimeLabel.frame.origin.x + size.width + 1;
    self.endTimeALabel.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)spotsWereUpdatedWithCount:(NSString *)count withLevelOfDetail:(NSString *)lod withSpot:(int)spotID {
    self.spot = [[self getParkingSpots] parkingSpotForID:self.spot.mID];
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
    [self.spot updateAsynchronouslyWithLevelOfDetail:@"all"];
    //[[self getParkingSpots] updateWithRequest:[NSDictionary dictionaryWithObject:@"all" forKey:@"level_of_detail"]];
}




@end
