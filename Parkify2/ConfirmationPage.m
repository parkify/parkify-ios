//
//  ConfirmationPage.m
//  Parkify
//
//  Created by Me on 1/23/13.
//
//

#import "ConfirmationPage.h"
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
#import "extendReservationViewController.h"

#define CALLOUT_CONTENT_OFFSET 20

@interface ConfirmationPage ()
@property (strong, nonatomic) NSMutableArray * scrollableSubviews;

@property (strong, nonatomic) UIWebView* calloutText;
@property (strong, nonatomic) CalloutView* congratsCallout;

@property (strong, nonatomic) UIWebView* directionsText;

@property (strong, nonatomic) UIWebView* notesText;

@property (strong, nonatomic) UIWebView* warningText;
@property (strong, nonatomic) UIView* warningContainer;
@property (strong, nonatomic) UIImageView* warningBackground;

@property (strong, nonatomic) UIWebView* telText;

@end

@implementation ConfirmationPage

@synthesize mainScrollView = _mainScrollView;

@synthesize reservation = _reservation;

@synthesize spot = _spot;

@synthesize scrollableSubviews = _scrollableSubviews;

@synthesize calloutText = _calloutText;
@synthesize congratsCallout = _congratsCallout;

@synthesize notesText = _notesText;

@synthesize warningText = _warningText;
@synthesize warningContainer = _warningContainer;
@synthesize warningBackground = _warningBackground;

@synthesize telText = _telText;

@synthesize topBarText = _topBarText;

@synthesize extendButton = _extendButton;


//I suggest you don't use this one.
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withSpot:nil withReservation:nil];
}


/*
 
 
 
 controller.spot = self.spot;
 if(paymentDetails != nil) {
 Acceptance *thetransaction = [Persistance addNewTransaction:self.spot withStartTime:self.rangeBar. selectedMinimumValue andEndTime:self.rangeBar.selectedMaximumValue andLastPaymentDetails:[paymentDetails objectForKey:@"details"] withTransactionID:[paymentDetails objectForKey:@"id"] ];
 [[Mixpanel sharedInstance] track:@"launchConfirmationVC" properties:nil];
 controller.transactionInfo = thetransaction;
 controller.topBarText = [paymentDetails objectForKey:@"details"];
 [Persistance saveCurrentSpot:self.spot];
 } else {
 controller.topBarText = @"";
 }
 
 controller.currentLat = self.currentLat;
 controller.currentLong = self.currentLong;
 

 */

- (id)initWithFrame:(CGRect)frame withSpot:(ParkingSpot *)spot withReservation:(Acceptance *)reservation
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
    self.spot = spot;
    self.reservation = reservation;
    self.topBarText = reservation.lastPaymentInfo;
    
    NSMutableDictionary* demoDict = [Persistance retrieveDemoDict];
    if (![demoDict objectForKey:@"ConfirmationViewControllerDemo"])
    {
        [demoDict setObject:[NSNumber numberWithBool:true] forKey:@"ConfirmationViewControllerDemo"];
        [self.scrollIndicator setAlpha:1.0];
        [Persistance saveDemoDict:demoDict];
    }
        UIScrollView* sview = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
    self.mainScrollView = sview;
    sview.layer.borderColor = [UIColor blackColor].CGColor;
    sview.layer.borderWidth = 2.0f;
    sview.backgroundColor = [UIColor colorWithWhite:0.17 alpha:1];
    [self addSubview:self.mainScrollView];
        
    
    [self.mainScrollView setDelegate:self];
    self.scrollableSubviews = [[NSMutableArray alloc] init];
    
    [self.mainScrollView setShowsVerticalScrollIndicator:false];
    
    MultiImageViewer* miViewer = [[MultiImageViewer alloc] initWithFrame:CGRectMake(0,0,self.mainScrollView.frame.size.width,self.mainScrollView.frame.size.width*0.5) withImageIds:self.spot.landscapeConfImageIDs];
    
    
    [self appendSubView:miViewer];
    
    [self prepCallout];
    
        //[self prepDirections];
    
    [self prepNotes];
    
    [self prepWarning];
    
    [self prepTel];
    
    
    if(self.topBarText) {
        [self prepTopBar];
    } else {
        [self.topBarView setHidden:true];
    }
        
    }
    return self;
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

-(void)prepExtendButton {
    CGRect calloutFrame = self.calloutText.frame;
    self.extendButton = [[UIButton alloc] initWithFrame:CGRectMake(calloutFrame.size.width-90, calloutFrame.size.height-30, 90, 30)];
    [self.extendButton setBackgroundImage:[UIImage imageNamed:@"small_blue_button.png"] forState:UIControlStateNormal];
    [self.extendButton setTitle:@"Extend" forState:UIControlStateNormal];
    [self.extendButton addTarget:self action:@selector(extendReservation:) forControlEvents:UIControlEventTouchUpInside];
    [self.calloutText addSubview:self.extendButton];
}
-(void)prepCallout {
    self.calloutText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.mainScrollView.frame.size.width - 2*CALLOUT_CONTENT_OFFSET,1)];
    self.calloutText.delegate = self;
    self.calloutText.backgroundColor = [UIColor clearColor];
    self.calloutText.opaque = false;
    [self.calloutText setUserInteractionEnabled:true];
    self.calloutText.scrollView.scrollEnabled = false;
    
    CGRect calloutFrame = [CalloutView frameThatFits:self.calloutText withCornerRadius:10];
    
    calloutFrame.origin.x = (self.mainScrollView.frame.size.width - calloutFrame.size.width) / 2.0;
    calloutFrame.origin.y = -8;
    
    self.congratsCallout = [[CalloutView alloc] initWithFrame:calloutFrame withXOffset:40 withCornerRadius:10 withInnerView:self.calloutText];
    [self appendSubView:self.congratsCallout];
    
    
    
    
    NSString* infoWebViewString;
    
    
    NSString* styleString = @"<style type='text/css'>"
    "body {background-color:transparent; font-family:'HelveticaNeue'; color:rgb(42,45,46);margin:0px;}"
    ".stressed1 {font-family:'HelveticaNeue-Bold'; font-size:16;}"
    ".stressed2 {font-family:'HelveticaNeue-Bold'; font-size:14;}"
    ".stressed3 {font-family:'HelveticaNeue'; font-size:14;}"
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
        NSString* timeString = @"";
        if (self.reservation) {
            double endtime = [[self.reservation endttime] doubleValue];
            
            timeString = [NSString stringWithFormat:@"%@ - %@", formatter([[self.reservation starttime] doubleValue]), formatter(endtime)];
        }
        //Layout text
        NSString* layoutString = ([self.spot.mSpotLayout isEqualToString:@"parallel"]) ? @"YES" : @"NO";
        //Layout text
        NSString* coverageString = ([self.spot.mSpotCoverage isEqualToString:@"covered"]) ? @"YES" : @"NO";
        
        
        
        infoWebViewString = [NSString stringWithFormat:@"<HTML>"
                             "<HEAD>%@</HEAD>"
                             "<BODY>"
                             "<span class='stressed1'>Parking Spot ID: #%@</span>"
                             "<br/>"
                             "<span class='stressed1'>%@</span>"
                             "<span class='smallspace'><br/><br/><br/></span>"
                             "<span class='stressed3'>Your reservation: </span>"
                             "<br/>"
                             "<span class='stressed2'>%@</span>"
                             "<br/>",
                             styleString,
                             [TextFormatter formatIdString:self.spot.mID],
                             self.spot.mAddress,
                             timeString];
    }
    
    
    [self.calloutText loadHTMLString:infoWebViewString baseURL:nil];
    
    //END CALLOUT
}

-(void)prepDirections {
    self.directionsText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.mainScrollView.frame.size.width,1)];
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
    self.notesText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.mainScrollView.frame.size.width,1)];
    self.notesText.delegate = self;
    self.notesText.backgroundColor = [UIColor clearColor];
    self.notesText.opaque = false;
    [self.notesText setUserInteractionEnabled:false];
    
    [self appendSubView:self.notesText];
    
    NSString* infoWebViewString;
    NSString* styleString = @"<style type='text/css'>"
    "body {background-color:transparent; font-family:'HelveticaNeue'; color:rgb(200,200,200); font-size:15; left-margin:0px; left-padding: 0px;}"
    "ul {list-style-position:inside; margin-left:0px; padding-left: 1px; padding-right: 1px;}"
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
    self.warningText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.mainScrollView.frame.size.width,1)];
    self.warningText.delegate = self;
    self.warningText.backgroundColor = [UIColor clearColor];
    self.warningText.opaque = false;
    [self.warningText setUserInteractionEnabled:false];
    
    self.warningContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,1)];
    
    self.warningBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.mainScrollView.frame.size.width,1)];
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
    "ul {list-style-position:inside; margin-left:0px; padding-left: 1px; padding-right: 1px;list-style-image: url(warning.png);}"
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
    self.telText = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.mainScrollView.frame.size.width,1)];
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
                             
                             "<span class='stressed2'><centered>Need Help? Call <a href='tel:1-855-727-5439'>1-855-Parkify</a></centered></span>"
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
    
    [self prepExtendButton];
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

- (IBAction)extendReservation:(id)sender {
    [self sendActionsForControlEvents:
     ExtendReservationRequestedActionEvent];
    
}

- (IBAction)topBarButtonTapped:(id)sender {
    [self hideTopBar:0.0];
}

- (void)moreToLeft:(BOOL)isMore {
    
}
- (void)moreToRight:(BOOL)isMore {
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
