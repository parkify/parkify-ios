//
//  DrivingDirectionsPage.m
//  Parkify
//
//  Created by Me on 1/25/13.
//
//

#import "DrivingDirectionsPage.h"
#import "ParkingSpot.h"
#import "SBJson.h"

@interface DrivingDirectionsPage()
@property CLLocationCoordinate2D location;
@end

@implementation DrivingDirectionsPage

@synthesize reservation = _reservation;
@synthesize spot = _spot;
@synthesize location = _location;


- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}


- (id)initWithFrame:(CGRect)frame withSpot:(ParkingSpot*)spot withReservation:(Acceptance*)reservation
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.spot = spot;
        self.reservation = reservation;
        
        self.location = CLLocationCoordinate2DMake(self.spot.mLat, self.spot.mLong);
        [self parseDirections];
        
        NSString *destination = [NSString stringWithFormat:@"%f, %f", self.location.latitude, self.location.longitude];
        
        NSString *title = @"Telenav HQ";
        
        NSString *token = @"fFWUlXmSdqNcCE2MBsexfEpB3hBl3Tv8n9ZmFpDWev1etAqujpLgIYfyhm5HK_ijJDQ2Qq2Z6F8V50HM_d1axaaMCIw6mm012fhCME9i5S0QJ64t_MF4Vq1itm6vVR7O5cV9FyvahgzF8EZc_2pA8qOGkBuf0K4GKZHQwR8UZm0";
        
        
        
        //make sure all parameters are URL encoded
        
        NSString *escapedUrlDestination = encodeToPercentEscapeString(destination);
        
        NSString *escapedUrlTitle = encodeToPercentEscapeString(title);
        
        NSString *escapedUrlToken = encodeToPercentEscapeString(token);
        
        
        
        NSString *endpoint = [NSString stringWithFormat: @"http://apps.scout.me/v1/driveto?dt=%@&title=%@&token=%@&name=Parkify", escapedUrlDestination, escapedUrlTitle, escapedUrlToken];
        [[Mixpanel sharedInstance] track:@"loadingDrivingDirections" properties:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:destination,endpoint,[NSNumber numberWithInt:self.spot.mID], nil] forKeys:[NSArray arrayWithObjects:@"destination",@"url",@"spotid", nil]]];
        
        
        UIView* container = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x + 5, frame.origin.y + 5, frame.size.width - 10, frame.size.height - 10)];
        
        container.layer.cornerRadius = 4;
        container.clipsToBounds = YES;
        container.layer.borderColor = [UIColor blackColor].CGColor;
        container.layer.borderWidth = 2.0f;
        [self addSubview:container];
        
        
        UIView* webViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height)];
        //webViewContainer.layer.borderColor = [UIColor blackColor].CGColor;
        //webViewContainer.layer.borderWidth = 2.0f;
        [webViewContainer setClipsToBounds:true];
        [container addSubview:webViewContainer];
        
        currWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -46, frame.size.width-10, frame.size.height+36)];
        currWebView.delegate = self;
        currWebView.scalesPageToFit = YES;
        
        
        
        [webViewContainer addSubview:currWebView];
        [currWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:endpoint]]];
        
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(currWebView.frame.size.width-50, currWebView.frame.size.height-50, 48,48)];
        [button addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:[UIColor blackColor]];
        //[self addSubview:button];
        
    }
    return self;
}


NSString* encodeToPercentEscapeString(NSString *string) {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        
                                                                        (__bridge CFStringRef) string,
                                                                        
                                                                        NULL,
                                                                        
                                                                        (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                        
                                                                        kCFStringEncodingUTF8) ;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
    
    
    
    NSMutableURLRequest *request = (NSMutableURLRequest *)req;
    
    if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
        
        //update User-Agent according to ScoutForApps spec
        
        [request setValue:[NSString stringWithFormat:@"%@ TNS4A/1.0", [request valueForHTTPHeaderField:@"User-Agent"]] forHTTPHeaderField:@"User-Agent"];
        
        
        
        //if you have a user id or device id in your app
        
        // [request setValue:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] forHTTPHeaderField:@"T-S4AID"];
        
    }
    
    
    
    return YES;
    
}

- (BOOL)parseDirections {
    NSDictionary* directions = [self.spot.mDirections JSONValue];
    
    NSArray* sources = [directions objectForKey:@"sources"];
    if(!sources || [sources count] <= 0) {
        return false;
    }
    NSArray* source = [sources objectAtIndex:0];
    
    
    if(!source) {
        return false;
    }
    
    NSDictionary* dirNode = [source objectAtIndex:0];
    if(!dirNode) {
        return false;
    }
    
    
    NSDictionary* location = [dirNode objectForKey:@"location"];
    if(location) {
        NSNumber* latitude = [location objectForKey:@"lat"];
        NSNumber* longitude = [location objectForKey:@"long"];
        if (latitude != NULL && longitude != NULL) {
            self.location = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        } else {
            return false;
        }
    } else {
        return false;
    }
    
    return true;
}


- (void)moreToLeft:(BOOL)isMore {
    
}
- (void)moreToRight:(BOOL)isMore {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    //get rid of popup
    [currWebView stringByEvaluatingJavaScriptFromString:@"$(\"#social_bubble\").hide()"];
}

- (void) test {
    
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
