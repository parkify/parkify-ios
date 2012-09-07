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
#import "Api.h"
#import "Persistance.h"

@interface ParkifyConfirmationViewController ()

@end

@implementation ParkifyConfirmationViewController

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize bottomScrollView = _bottomScrollView;
@synthesize bottomWebView = _bottomWebView;
@synthesize imageView = _imageView;
@synthesize topWebView = _topWebView;
@synthesize topScrollView = _topScrollView;

@synthesize titleLable = _titleLable;
@synthesize spot = _spot;
@synthesize infoBox = _infoBox;
@synthesize timeLabel = _timeLabel;
@synthesize priceLabel = _priceLabel;

@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;

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
    
    
    //image(s)
    [self addPicture];
    [self fillTopWebView];
    [self fillBottomWebView];
    
	// Do any additional setup after loading the view.
    [self updateInfo];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setTopWebView:nil];
    [self setTopScrollView:nil];
    [self setBottomWebView:nil];
    [self setBottomScrollView:nil];
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
        infoTitle = [NSString stringWithFormat:@"Parkify Spot"];
        infoBody = self.spot.mDesc; 
        
        //Time text
        Formatter formatter = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            return [dateFormatter stringFromDate:time]; };
        
        timeString = [NSString stringWithFormat:@"Time Booked: %@ - %@", formatter(self.startTime), formatter(self.endTime)];
        
        //Price text
        double durationInSeconds = (self.endTime - self.startTime);
        double totalPrice;
        if(self.spot.offers.count > 0) {
             totalPrice = [self.spot priceFromNowForDurationInSeconds:durationInSeconds];
            
            [Persistance saveLastAmountCharged:totalPrice];
        } else {
            totalPrice = [Persistance retrieveLastAmountCharged];
        }
        priceString = [NSString stringWithFormat:@"$%0.2f Charged to ************%@", totalPrice, [Persistance retrieveLastFourDigits]];
        
    }
    CGAffineTransform squish = [TextFormatter transformForSpotViewText];
    self.titleLable.text = infoTitle;
    [self.infoBox setText:infoBody];
    self.timeLabel.text = timeString;
    self.timeLabel.transform = squish;
    self.priceLabel.text = priceString;
    self.priceLabel.transform = squish;
    
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
    
        

}
- (IBAction)directionsButtonTapped:(UIButton *)sender {
    NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
                     self.currentLat,self.currentLong,//currentLocation.latitude, currentLocation.longitude,
                     self.spot.mLat, self.spot.mLong];//[address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];

}

/** TODO: Make this javascript-enabled to update it **/
-(void)fillTopWebView {
    NSString* infoWebViewString;
    NSString* styleString = @"<style type=\"text/css\">"
    //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
    ".top { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:14; color:black }"
    ".mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#A9A9A9 }"
    ".bottom { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:16; color:black }"
    "</style>";
    if(self.spot == nil) {
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>Spot Not Available.</body></html>", styleString];
    }
    else {
        //Info web view text
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>"
                             "<span class=top>%@</span></br>"
                             "<hr/>"
                             "<span class=mid>Difficulty: %@</span></br>"
                             "<span class=mid>Covered: %@</span></br><hr/>"
                             "<span class=mid>%@</span>"
                             "</body></html>",
                             styleString,
                             self.spot.mAddress,
                             self.spot.mSpotDifficulty,
                             self.spot.mSpotCoverage,
                             self.spot.mDesc];
    }
    [self.topWebView loadHTMLString:infoWebViewString baseURL:nil];
    
    CGRect frame = self.topWebView.frame;
    frame.size.height = 1;
    self.topWebView.frame = frame;
    CGSize fittingSize = [self.topWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    self.topWebView.frame = frame;
    self.topScrollView.contentSize = frame.size;
    
}

/** TODO: Make this javascript-enabled to update it **/
-(void)fillBottomWebView {
    NSString* infoWebViewString;
    NSString* styleString = @"<style type=\"text/css\">"
    //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
    ".top { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:14; color:black }"
    ".mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#A9A9A9 }"
    ".bottom { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:16; color:black }"
    "</style>";
    if(self.spot == nil) {
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>Spot Not Available.</body></html>", styleString];
    }
    else {
        //Info web view text
        NSString* directions = [self.spot.mDirections stringByReplacingOccurrencesOfString:@"\n"
                                                                   withString:@"<br\>"];
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>"
                             "<span class=top>Directions for Spot #%@</span></br>"
                             "<hr/>"
                             "<span class=mid>%@</span></br>"
                             "</body></html>",
                             styleString,
                             [TextFormatter formatIdString:self.spot.mID],
                             directions];
    }
    [self.bottomWebView loadHTMLString:infoWebViewString baseURL:nil];
    
    CGRect frame = self.bottomWebView.frame;
    frame.size.height = 1;
    self.bottomWebView.frame = frame;
    CGSize fittingSize = [self.bottomWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    self.bottomWebView.frame = frame;
    self.bottomScrollView.contentSize = frame.size;
    
}



-  (void)addPicture {
    if (self.spot.imageIDs != NULL && [self.spot.imageIDs count] != 0) {
        int imageID = [[self.spot.imageIDs objectAtIndex:0] intValue];
        [Api downloadImageDataAsynchronouslyWithId:imageID withStyle:@"original" withSuccess:^(NSDictionary * result) {
            self.imageView.image = [UIImage imageWithData:[result objectForKey:@"image"]];
        } withFailure:^(NSError * err) {
            ;
        }];
    }
}
@end
