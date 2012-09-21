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
#import <AddressBook/AddressBook.h>

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
@synthesize pictureActivityView = _pictureActivityView;

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
    [self setPictureActivityView:nil];
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
    
    
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        // ios >= 6
        
        CLLocationCoordinate2D end;
        end.latitude = self.spot.mLat;
        end.longitude = self.spot.mLong;
        
        NSArray* addressComponents = [self.spot.mAddress componentsSeparatedByString:@", "];
        
        NSArray* addressKeysAll = [NSArray arrayWithObjects:kABPersonAddressStreetKey,
            kABPersonAddressCityKey,
            kABPersonAddressStateKey,
            kABPersonAddressZIPKey,
            kABPersonAddressCountryKey,
            kABPersonAddressCountryCodeKey, nil];
        
        NSRange matchedRange;
        matchedRange.location = 0;
        matchedRange.length = [addressComponents count];
        
                
        NSDictionary* addressDictionary = [NSDictionary dictionaryWithObjects:addressComponents forKeys:[addressKeysAll subarrayWithRange:matchedRange]];
        
        // NSDictionary addressDictionary =
        
        MKPlacemark* endPlacemark = [[MKPlacemark alloc] initWithCoordinate:end addressDictionary:addressDictionary];
        //MKPlacemark* endPlacemark = [[MKPlacemark alloc] initWithCoordinate:end addressDictionary:nil];
        NSArray* startAndEnd = [NSArray arrayWithObjects:[MKMapItem mapItemForCurrentLocation], [[MKMapItem alloc] initWithPlacemark:endPlacemark], nil];
        
        NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey, nil];
        [MKMapItem openMapsWithItems:startAndEnd launchOptions:options];
    } else {
        // ios < 6
        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
                         self.currentLat,self.currentLong,//currentLocation.latitude, currentLocation.longitude,
                         self.spot.mLat, self.spot.mLong];//[address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
    
}

/** TODO: Make this javascript-enabled to update it **/
-(void)fillTopWebView {
    NSString* infoWebViewString;
    
    NSString* styleString = @"<style type=\"text/css\">"
    //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
    ".top { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:14; color:black; }"
    ".top-mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#224455; }"
    ".mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#556677; }"
    ".bottom { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:16; color:black; }"
    ".selected { color:#224455; } "
    ".faded { color:#99AABB; } "
    "</style>";

    
    
    /*
    NSString* styleString = @"<style type=\"text/css\">"
    //"body { background-color:transparent; font-family:Marker Felt; font-size:12; color:white}"
    ".top { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:14; color:black }"
    ".mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#778899 }"
    ".bottom { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:16; color:black }"
    "</style>";
     
    */
    if(self.spot == nil) {
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>Spot Not Available.</body></html>", styleString];
    }
    else {
        
        
        NSString* layoutString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"parallel"]) {
            layoutString = @"<span class=faded>regular</span> / <span class=selected>parallel</span>";
        } else {
            layoutString = @"<span class=selected>regular</span> / <span class=faded>parallel</span>";
        }
        
        NSString* coverageString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"covered"]) {
            coverageString = @"<span class=faded>open air</span> / <span class=selected>covered";
        } else {
            coverageString = @"<span class=selected>open air</span> / <span class=faded>covered</span>";
        }
        
        
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
                             layoutString,
                             coverageString,
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
    "body {font-family:\"Arial Rounded MT Bold\";}"
    ".box { border:2px dashed #89CFF0; }"
    ".top { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:14; color:black; }"
    ".top-mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#224455; }"
    ".mid { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:10; color:#556677; }"
    ".bottom { background-color:transparent; font-family:\"Arial Rounded MT Bold\"; font-size:16; color:black; }"
    ".selected { color:#224455; } "
    ".faded { color:#99AABB; } "
    "</style>";
    if(self.spot == nil) {
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>Spot Not Available.</body></html>", styleString];
    }
    else {
        //Info web view text
        
        //Time text
        Formatter formatter = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            return [dateFormatter stringFromDate:time]; };
        
        NSString* timeString = [NSString stringWithFormat:@"%@ - %@", formatter(self.startTime), formatter(self.endTime)];
        
        //Layout text
        NSString* layoutString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"parallel"]) {
            layoutString = @"<span class=faded>regular</span> / <span class=selected>parallel</span>";
        } else {
            layoutString = @"<span class=selected>regular</span> / <span class=faded>parallel</span>";
        }
        
        //Coverage text
        NSString* coverageString = @"";
        if ([self.spot.mSpotLayout isEqualToString:@"covered"]) {
            coverageString = @"<span class=faded>open air</span> / <span class=selected>covered";
        } else {
            coverageString = @"<span class=selected>open air</span> / <span class=faded>covered</span>";
        }
        
        //Price text
        double durationInSeconds = (self.endTime - self.startTime);
        double totalPrice;
        if(self.spot.offers.count > 0) {
            totalPrice = [self.spot priceFromNowForDurationInSeconds:durationInSeconds];
            
            [Persistance saveLastAmountCharged:totalPrice];
        } else {
            totalPrice = [Persistance retrieveLastAmountCharged];
        }
        NSString* priceString = [NSString stringWithFormat:@"Credit Card ****-****-****-%@<br/>was charged $%0.2f",[Persistance retrieveLastFourDigits],totalPrice];

        
        
        NSString* directions = [self.spot.mDirections stringByReplacingOccurrencesOfString:@"\n" withString:@"</li><li>"];
        
        infoWebViewString = [NSString stringWithFormat:@"<html>%@<body>"
                             "<div class=\"box\"><center><h3>Congratulations!</h2><span class=top><p>You bought parking spot #%@<br/>at: %@<br/>Your reservation:<br/>%@</p></span></center></div>"
                             
                            
                             "<div class=\"box\"><span class=top>How to find your spot:</span>"
                             "<span class=mid><ul><li>%@</li></ul></span></div>"
                             
                             "<div class=\"box\"><span class=top>Note:</span><br/>"
                             "<div style=\"margin:0px 5px;\">"
                             "<span class=mid>Please don't encroach on the other spots. For spots with no white lines, please make sure every spot has enugh space for the person who parks there. WARNING: Your car will be towed if you stay past your reservation time or if you park in a spot that does not match your reservation.</span></div></div>"
                             
                             "<div class=\"box\"><center>"
                             "<span class=mid>Difficulty: %@</span></br>"
                             "<span class=mid>Covered: %@</span></center></div>"
                             
                             "<div class=\"box\"><center>"
                             "<span class=bottom>%@</br>Need Help? Call 1-855-Parkify</span></center></div>"
                             
                             
                             "</body></html>",
                             styleString,
                             
                             [TextFormatter formatIdString:self.spot.mID],
                             self.spot.mAddress,
                             timeString,
                             directions,
                             layoutString,
                             coverageString,
                             priceString
                             ];
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
        [self.pictureActivityView startAnimating];
        [Api downloadImageDataAsynchronouslyWithId:imageID withStyle:@"original" withSuccess:^(NSDictionary * result) {
            self.imageView.image = [UIImage imageWithData:[result objectForKey:@"image"]];
            [self.pictureActivityView stopAnimating];
            [self.pictureActivityView setHidden:true];
        } withFailure:^(NSError * err) {
            self.imageView.image = [UIImage imageNamed:@"NoPic.png"];
            [self.pictureActivityView stopAnimating];
            [self.pictureActivityView setHidden:true];
        }];
    }
}
@end
