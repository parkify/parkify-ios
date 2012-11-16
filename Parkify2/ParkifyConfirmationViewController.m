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
#import "MultiImageViewer.h"
#import "CalloutView.h"
#import "DirectionsControl.h"
#import "problemSpotViewController.h"
#import "troubleFindingSpotViewController.h"
#import "MyWebView.h"
#import "mapDirectionsViewController.h"
//#import "PlacedAgent.h"

#define CALLOUT_CONTENT_OFFSET 20

@interface ParkifyConfirmationViewController ()
@property (strong, nonatomic) NSMutableArray * scrollableSubviews;

@property (strong, nonatomic) UIWebView* calloutText;
@property (strong, nonatomic) CalloutView* congratsCallout;

@property (strong, nonatomic) UIWebView* directionsText;

@property (strong, nonatomic) UIWebView* notesText;

@property (strong, nonatomic) UIWebView* warningText;
@property (strong, nonatomic) UIView* warningContainer;
@property (strong, nonatomic) UIImageView* warningBackground;

@property (strong, nonatomic) UIWebView* telText;

@property (nonatomic, strong) UIViewController *detailVC;


@end

@implementation ParkifyConfirmationViewController

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize mainScrollView = _mainScrollView;

@synthesize titleLable = _titleLable;
@synthesize spot = _spot;

@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;

@synthesize scrollableSubviews = _scrollableSubviews;

@synthesize calloutText = _calloutText;
@synthesize congratsCallout = _congratsCallout;

@synthesize notesText = _notesText;

@synthesize warningText = _warningText;
@synthesize warningContainer = _warningContainer;
@synthesize warningBackground = _warningBackground;

@synthesize telText = _telText;

@synthesize topBarText = _topBarText;
@synthesize detailVC = _detailVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollableSubviews = [[NSMutableArray alloc] init];
    
    
    
    
    UIView* testView1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,160)];
    testView1.backgroundColor = [UIColor clearColor];
    
    MultiImageViewer* miViewer = [[MultiImageViewer alloc] initWithFrame:CGRectMake(0,0,320,160) withImageIds:self.spot.landscapeConfImageIDs];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [titleView setFont:[UIFont fontWithName:@"Helvetica Light" size:36.0f]];
    [titleView setTextColor:[UIColor colorWithRed:197.0f/255.0f green:211.0f/255.0f blue:247.0f/255.0f alpha:1.0f]];
    [titleView setText:@"Congratulations!"];
    [titleView sizeToFit];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setTitleView:titleView];
    
    [self appendSubView:miViewer];
    
    [self prepCallout];
    
    [self prepDirections];
    
    [self prepNotes];
    
    [self prepWarning];
    
    [self prepTel];
    
    
    if(self.topBarText) {
        [self prepTopBar];
    } else {
        [self.topBarView setHidden:true];
    }
    
    
    //[PlacedAgent logPageView:@"SpotConfView"];
    
    
    //image(s)
    //[self addPicture];
    
    //[self addAllPictures];
    
    //[self fillTopWebView];
    //[self fillBottomWebView];
    
	// Do any additional setup after loading the view.
    //[self updateInfo];
}

- (void)viewDidUnload
{
    [self setMainScrollView:nil];
    [self setTopBarView:nil];
    [self setTopViewLabel:nil];
    [self setTopBarTapped:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//Adds view to the bottom of the scrollview
-(void) appendSubView:(UIView*)view {
    float y = 0;
    float lastViewY = 0;
    float lastViewHeight = 0;
    if(!self.scrollableSubviews) {
        return;
    }
    if (self.scrollableSubviews.count != 0) {
        lastViewY = ((UIView*)self.scrollableSubviews.lastObject).frame.origin.y;
        lastViewHeight = ((UIView*)self.scrollableSubviews.lastObject).frame.size.height;
    }
    y = lastViewY + lastViewHeight + view.frame.origin.y;
    CGRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
    
    [self.scrollableSubviews addObject:view];
    [self.mainScrollView addSubview:view];
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, y + view.frame.size.height);
}

-(void)adjustSubView:(UIView*)viewToAdjust byOffset:(CGPoint)offset bySizeIncrease:(CGSize)sizeIncrease animated:(BOOL)animated {
    [UIView animateWithDuration:((animated) ? 0.4 : 0)
                     animations:^{
                         BOOL afterViewToAdjust = false;
                         float offsetOtherViews = offset.y + sizeIncrease.height;
                         for (UIView* view in self.scrollableSubviews) {
                             if(view == viewToAdjust) {
                                 CGRect frame = view.frame;
                                 frame.origin.x += offset.x;
                                 frame.origin.y += offset.y;
                                 frame.size.width += sizeIncrease.width;
                                 frame.size.height += sizeIncrease.height;
                                 view.frame = frame;
                                 afterViewToAdjust = true;
                             } else if (afterViewToAdjust) {
                                 CGRect frame = view.frame;
                                 frame.origin.y += offsetOtherViews;
                                 view.frame = frame;
                                 afterViewToAdjust = true;
                             }
                         }
                         CGSize contentSize = self.mainScrollView.contentSize;
                         contentSize.height += offsetOtherViews;
                         self.mainScrollView.contentSize = contentSize;
                         
                     }];
}


-(void)prepCallout {
    self.calloutText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width - 2*CALLOUT_CONTENT_OFFSET,1)];
    self.calloutText.delegate = self;
    self.calloutText.backgroundColor = [UIColor clearColor];
    self.calloutText.opaque = false;
    [self.calloutText setUserInteractionEnabled:false];
    
    CGRect calloutFrame = [CalloutView frameThatFits:self.calloutText withCornerRadius:10];
    
    calloutFrame.origin.x = (self.view.frame.size.width - calloutFrame.size.width) / 2.0;
    calloutFrame.origin.y = -8;
    
    self.congratsCallout = [[CalloutView alloc] initWithFrame:calloutFrame withXOffset:40 withCornerRadius:10 withInnerView:self.calloutText];
    [self appendSubView:self.congratsCallout];
    
    
    NSString* infoWebViewString;
    
    
    NSString* styleString = @"<style type='text/css'>"
    "body {background-color:transparent; font-family:'HelveticaNeue'; color:rgb(42,45,46);margin:0px;}"
    ".stressed1 {font-family:'HelveticaNeue-Bold'; font-size:18;}"
    ".stressed2 {font-family:'HelveticaNeue-Bold'; font-size:15;}"
    ".stressed3 {font-family:'HelveticaNeue'; font-size:15;}"
    ".smallspace {font-size:5;}"
    ".error {color:rgb(255,97,97);}"
    "</style>";
    
    if(!self.spot) {
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             
                             "<div id='content'>"
                             "<span class='stressed1 error'>Error!</span>"
                             "<br/>"
                             "<span class='stressed3 error'>Problem finding reservation. Please call <a href='tel:1-855-727-5439'>1-855-Parkify</a> for assistance.</span>"
                             "</div></BODY></HTML>", styleString];
    } else {
        
        //Time text
        Formatter formatter = ^(double val) {
            NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:val];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            return [dateFormatter stringFromDate:time]; };
        
        NSString* timeString = [NSString stringWithFormat:@"%@ - %@", formatter(self.startTime), formatter(self.endTime)];
        
        //Layout text
        NSString* layoutString = ([self.spot.mSpotLayout isEqualToString:@"parallel"]) ? @"YES" : @"NO";
        //Layout text
        NSString* coverageString = ([self.spot.mSpotCoverage isEqualToString:@"covered"]) ? @"YES" : @"NO";
        

        
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "<div id='content'>"
                             "<span class='stressed1'>Congratulations!</span>"
                             "<span class='stressed3'> You bought</span>"
                             "<br/>"
                             "<span class='stressed3'>Parking spot with Unique ID: </span>"
                             "<span class='stressed2'>#%@ </span>"
                             "<span class='stressed3'>at</span>"
                             "<br/>"
                             "<span class='stressed2'>%@</span>"
                             "<span class='smallspace'><br/><br/><br/></span>"
                             "<span class='stressed3'>Your reservation: </span>"
                             "<span class='stressed2'>%@</span>"
                             "<br/>"
                             "<span class='stressed3'>Parallel parking: </span>"
                             "<span class='stressed2'>%@ | </span>"
                             "<span class='stressed3'>Covered: </span>"
                             "<span class='stressed2'>%@</span>"
                             "</div></BODY></HTML>",
                             styleString,
                             [TextFormatter formatIdString:self.spot.mID],
                             self.spot.mAddress,
                             timeString,
                             layoutString,
                             coverageString];
    }
    
    
    [self.calloutText loadHTMLString:infoWebViewString baseURL:nil];
    
    //END CALLOUT
}

-(void)prepDirections {
    self.directionsText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,1)];
    self.directionsText.delegate = self;
    self.directionsText.backgroundColor = [UIColor clearColor];
    self.directionsText.opaque = false;
    [self.directionsText setUserInteractionEnabled:true];
    
    //self.directionsText.scrollView.scrollEnabled = false;
    
    
    [self appendSubView:self.directionsText];
    
    
    
    NSString* infoWebViewString = @"";
    
    
    NSString* styleString = @"<style type='text/css'>"
    "body {background-color:transparent; font-family:'HelveticaNeue'; color:rgb(97,189,250);}"
    ".stressed1 {font-family:'HelveticaNeue-Bold'; font-size:18;}"
    ".stressed2 {font-family:'HelveticaNeue-Bold'; font-size:15;}"
    ".stressed3 {font-family:'HelveticaNeue'; font-size:15;}"
    ".smallspace {font-size:5;}"
    ".error {color:rgb(255,97,97);}"
    "img {border-width:4px; border-style:solid; border-color:rgb(97,189,250); float:left; width:150px; height:100px;}"
    ".direction {margin-top:10px;}"
    "</style>"
    ;
     
    if(!self.spot) {
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "</BODY></HTML>", styleString];
    } else {
        /*
        
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "<div id='content'>"
                             "<span class='stressed1'>How to find your spot</span>"
                             "<br/>"
                             "<div class='direction'><img id=target src='%@'/>blahblahblah adsfsda mewownwefkl nawlnflwef mkwefjwlke flkawefklwaemf wekfmlkwe mweafwelkfm lkwemakwefmlkwem awkemfewk.</div>"
                             
                             "</div></BODY></HTML>",
                             styleString,
                             [NSString stringWithFormat:@"http://%@/images/%d?image_attachment=true&style=original", TARGET_SERVER, [[self.spot.imageIDs objectAtIndex:0] intValue]]];
         */
        
        DirectionsControl* dControl = [[DirectionsControl alloc] initWithFrame:CGRectZero withDirections:self.spot.mDirections withResolutionDelegate:self.spot];
        infoWebViewString = [dControl htmlForDirections];
    }
    
    
    [self.directionsText loadHTMLString:infoWebViewString baseURL:nil];
    
    //END CALLOUT
}

-(void) prepNotes {
    self.notesText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,1)];
    self.notesText.delegate = self;
    self.notesText.backgroundColor = [UIColor clearColor];
    self.notesText.opaque = false;
    [self.notesText setUserInteractionEnabled:false];
    
    [self appendSubView:self.notesText];
    
    NSString* infoWebViewString;
    NSString* styleString = @"<style type='text/css'>"
    "body {background-color:transparent; font-family:'HelveticaNeue'; color:rgb(200,200,200); font-size:15; left-margin:0px; left-padding: 0px;}"
    "ul {list-style-position:inside; margin-left:0px; padding-left: 1px;}"
    "</style>";
    
    if(!self.spot) {
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "<div id='content'>"
                             "</div></BODY></HTML>", styleString];
    } else {
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "<ul>"
                             "<li>Please don't encroach on other spots.</li>"
                             "<li>If there are no white lines, make sure every spot has enough space for those who park there.</li>"
                             "<li>If your spot has a Parkify sign or sticker, make sure the Unique ID matches the number on your reservation confirmation.</li>"
                             "</ul>"
                             "</BODY></HTML>",
                             styleString
                             ];
    }
    
    
    [self.notesText loadHTMLString:infoWebViewString baseURL:nil];
    
}

-(void) prepWarning {
    self.warningText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,1)];
    self.warningText.delegate = self;
    self.warningText.backgroundColor = [UIColor clearColor];
    self.warningText.opaque = false;
    [self.warningText setUserInteractionEnabled:false];
    
    self.warningContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,1)];
    
    self.warningBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,1)];
    self.warningBackground.image = [UIImage imageNamed:@"warning_background.png"];
    
    [self.warningContainer addSubview:self.warningBackground];
    [self.warningContainer addSubview:self.warningText];
    
    [self appendSubView:self.warningContainer];
    
    NSString* infoWebViewString;
    NSString* styleString = @"<style type='text/css'>"
    "body {background-color:transparent; font-family:'HelveticaNeue'; color:rgb(255,236,98); font-size:15; left-margin:0px; left-padding: 0px;}"
    ".stressed1 {font-family:'HelveticaNeue-Bold'; font-size:18;}"
    ".stressed2 {font-family:'HelveticaNeue-Bold'; font-size:15;}"
    ".stressed3 {font-family:'HelveticaNeue'; font-size:15;}"
    "ul {list-style-position:inside; margin-left:0px; padding-left: 1px; list-style-image: url(warning.png);}"
    "</style>";
    
    if(!self.spot) {
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "<div id='content'>"
                             "</div></BODY></HTML>", styleString];
    } else {
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "<ul><li>"
                             "<span class='stressed1'>Warning</span>"
                             "</br>"
                             "<span class='stressed3'>Your car may be towed if you stay past your reseration time or if you park in a spot that does not match your reservation.</span>"
                             "</li></ul>"
                             "</BODY></HTML>",
                             styleString
                             ];
    }
    
    NSString* path = [[NSBundle mainBundle] bundlePath];
    NSURL* baseURL = [NSURL fileURLWithPath:path];
    
    [self.warningText loadHTMLString:infoWebViewString baseURL:baseURL];
    
}

-(void) prepTel {
    self.telText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,1)];
    self.telText.delegate = self;
    self.telText.backgroundColor = [UIColor clearColor];
    self.telText.opaque = false;
    //[self.telText setUserInteractionEnabled:false];
    
    [self appendSubView:self.telText];
    
    NSString* infoWebViewString;
    NSString* styleString = @"<style type='text/css'>"
    "body {background-color:transparent; font-family:'HelveticaNeue'; color:rgb(255,255,255);}"
    ".stressed1 {font-family:'HelveticaNeue-Bold'; font-size:18;}"
    ".stressed2 {font-family:'HelveticaNeue-Bold'; font-size:15;}"
    ".stressed3 {font-family:'HelveticaNeue'; font-size:15;}"
    "ul {list-style-position:inside; margin-left:0px; padding-left: 1px; list-style-image: url(warning.png);}"
    "a {text-decoration:none; color:rgb(97,189,250);}"
    "</style>";
    
    if(!self.spot) {
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "<div id='content'>"
                             "</div></BODY></HTML>", styleString];
    } else {
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             
                             "<span class='stressed2'>Need Help? Call <a href='tel:1-855-727-5439'>1-855-Parkify</a></span>"                             
                             "</BODY></HTML>",
                             styleString
                             ];
    }
    
    [self.telText loadHTMLString:infoWebViewString baseURL:nil];
    
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    //figure out min doc height
    
    CGRect frame = aWebView.frame;
    float prevHeight = frame.size.height;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGFloat height = [[aWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    
    frame.size.height = prevHeight;
    aWebView.frame = frame;
    
    
    if(aWebView == self.calloutText) {
        
        //in callout, so safe to set frame here.
        frame.size.height = height;
        aWebView.frame = frame;
        
        //now adjust the callout.
        [self finishSettingUpCallout];
        
    } else if (aWebView == self.directionsText) {
        
        CGPoint offset = CGPointMake(0,0);
        CGSize sizeIncrease = CGSizeMake(0, height - prevHeight);
        [self adjustSubView:self.directionsText byOffset:offset bySizeIncrease:sizeIncrease animated:true];
    } else if (aWebView == self.notesText) {
        
        CGPoint offset = CGPointMake(0,0);
        CGSize sizeIncrease = CGSizeMake(0, height - prevHeight);
        [self adjustSubView:self.notesText byOffset:offset bySizeIncrease:sizeIncrease animated:true];
    } else if (aWebView == self.warningText) {
        //in container, so safe to set frame here.
        frame.size.height = height;
        aWebView.frame = frame;
        
        //also background image
        self.warningBackground.frame = frame;
    
        CGPoint offset = CGPointMake(0,0);
        CGSize sizeIncrease = CGSizeMake(0, height - prevHeight);
        [self adjustSubView:self.warningContainer byOffset:offset bySizeIncrease:sizeIncrease animated:true];
    } else if (aWebView == self.telText) {
        
        CGPoint offset = CGPointMake(0,0);
        CGSize sizeIncrease = CGSizeMake(0, height - prevHeight);
        [self adjustSubView:self.telText byOffset:offset bySizeIncrease:sizeIncrease animated:true];
    }



}
- (void)finishSettingUpCallout {
    CGRect newCalloutFrame = [self.congratsCallout frameThatFits];
    CGPoint offset = CGPointMake(0,0);
    CGSize sizeIncrease = CGSizeMake(newCalloutFrame.size.width - self.congratsCallout.frame.size.width,
                                 newCalloutFrame.size.height - self.congratsCallout.frame.size.height);
    
    [self adjustSubView:self.congratsCallout byOffset:offset bySizeIncrease:sizeIncrease animated:true];
}

//Capture resize event from the images.
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];
    if ([[URL scheme] isEqualToString:@"yourscheme"]) {
        // parse the rest of the URL object and execute functions
        [self webViewDidFinishLoad:webView];
        return false;
    } else {
        return true;
    }
}

/*
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
*/

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
}

- (IBAction)directionsButtonTapped:(UIButton *)sender {
    mapDirectionsViewController *newMaps = [[mapDirectionsViewController alloc] init];
    
    //MyWebView *newMaps = [[MyWebView alloc] initWithFrame:self.view.frame];
    newMaps.currLat=self.currentLat;
    newMaps.currLong = self.currentLong;
    newMaps.spotLat = self.spot.mLat;
    newMaps.spotLong =self.spot.mLong;
    [self.navigationController pushViewController:newMaps animated:YES];
//    [self.view addSubview:newMaps];
    return;
    
    
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        // ios >= 6
        
        CLLocationCoordinate2D end;
        end.latitude = self.spot.mLat;
        end.longitude = self.spot.mLong;
        
        
        NSArray* addressComponents = [self.spot.mAddress componentsSeparatedByString:@","];
        NSMutableArray* trimmedAddressComponents = [[NSMutableArray alloc] init];
        for (NSString* str in addressComponents) {
            [trimmedAddressComponents addObject:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
        
        
        NSArray* addressKeysAll = [NSArray arrayWithObjects:kABPersonAddressStreetKey,
            kABPersonAddressCityKey,
            kABPersonAddressStateKey,
            kABPersonAddressZIPKey,
            kABPersonAddressCountryKey,
            kABPersonAddressCountryCodeKey, nil];
        
        NSRange matchedRange;
        matchedRange.location = 0;
        matchedRange.length = [addressComponents count];
        
                
        NSDictionary* addressDictionary = [NSDictionary dictionaryWithObjects:trimmedAddressComponents forKeys:[addressKeysAll subarrayWithRange:matchedRange]];
        
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

-(void) prepTopBar {
    self.topViewLabel.text = self.topBarText;
    
    [self.topBarView setUserInteractionEnabled:true];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.topBarView setAlpha:0.77];
    } completion:^(BOOL finished) {
        [self hideTopBar:12.0];
    }];
}

-(void) hideTopBar:(float)delay {
    
    [UIView animateWithDuration:0.2 delay:delay options: UIViewAnimationOptionCurveEaseOut animations:^{
        [self.topBarView setAlpha:self.topBarView.alpha+0.20];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.topBarView setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            [self.topBarView setHidden:true];
        }];
    }];
}

- (IBAction)topBarButtonTapped:(id)sender {
    [self hideTopBar:0.0];
}
#pragma mark Gaurav code for trouble
-(void)launchProblemSpotVC:(BOOL)isLicensePlateView{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];

    problemSpotViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProblemSpotVC"];
    self.detailVC=controller;
    ((problemSpotViewController*)(self.detailVC)).isLicensePlateProblem=isLicensePlateView;
    [self.navigationController pushViewController:self.detailVC animated:YES];
    
}
-(void)launchtroubleFindingVC{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    
    self.detailVC = [mainStoryboard instantiateViewControllerWithIdentifier: @"troubleFindingVC"];
    [self.navigationController pushViewController:self.detailVC animated:YES];
    
}
#pragma mark alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kProblemAlertView && buttonIndex != alertView.cancelButtonIndex){
        if (buttonIndex == 1)
            [self launchProblemSpotVC:TRUE];
        else if(buttonIndex==2){
            [self launchProblemSpotVC:FALSE];
            
            NSLog(@"Launch without the license plate stuff");
        }
        else{
            [self launchtroubleFindingVC];
            NSLog(@"Launch directions");
        }
    }
}
- (IBAction)launchTroubleAlert:(id)sender {
    UIAlertView *problemWithSpot = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"Please let us know what problem you are having we'll be happy to give you a refund." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Somebody is in my spot",@"The spot is unusable", @"I cannot find my spot!", nil];
    [problemWithSpot show];
    problemWithSpot.tag = kProblemAlertView;
    
    
}


@end
