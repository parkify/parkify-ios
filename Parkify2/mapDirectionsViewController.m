//
//  mapDirectionsViewController.m
//  Parkify
//
//  Created by gnamit on 11/12/12.
//
//

#import "mapDirectionsViewController.h"
#import "MyWebView.h"
#import "WaitingMask.h"
#import "UIDevice+IdentifierAddition.h"
@interface mapDirectionsViewController ()
{
    
}
@property (nonatomic, strong) WaitingMask* waitingMask;

@end

@implementation mapDirectionsViewController
@synthesize currLat;
@synthesize currLong;
@synthesize spotLat;
@synthesize spotLong;
@synthesize waitingMask = _waitingMask;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)switchDirs{
    textDirs= !textDirs;

    if(textDirs){
        [currWebView stringByEvaluatingJavaScriptFromString:@"showText()"];
    }
    else{
        [currWebView stringByEvaluatingJavaScriptFromString:@"showMap()"];

    }
    NSString *buttontext = @"Map";
    if(!textDirs){
        buttontext=@"Text";
    }
   /* CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];
*/
    UIBarButtonItem *switchToText = [[UIBarButtonItem alloc] initWithTitle:buttontext style:UIBarButtonItemStyleBordered target:self action:@selector(switchDirs)];
    [self.navigationItem setRightBarButtonItem:switchToText];

}
NSString* encodeToPercentEscapeString(NSString *string) {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                         
                                                                         (__bridge CFStringRef) string,
                                                                         
                                                                         NULL,
                                                                         
                                                                         (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                         
                                                                         kCFStringEncodingUTF8) ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    

    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [titleView setFont:[UIFont fontWithName:@"Helvetica Light" size:36.0f]];
    [titleView setTextColor:[UIColor colorWithRed:197.0f/255.0f green:211.0f/255.0f blue:247.0f/255.0f alpha:1.0f]];
    [titleView setText:@"Directions"];
    [titleView sizeToFit];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setTitleView:titleView];
   /* currWebView = [[MyWebView alloc] initWithFrame:self.view.frame];
    currWebView.customdelegate=self;
    [self.view addSubview:currWebView];
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];

    textDirs=FALSE;
    UIBarButtonItem *switchToText = [[UIBarButtonItem alloc] initWithTitle:@"Text" style:UIBarButtonItemStyleBordered target:self action:@selector(switchDirs)];
    [self.navigationItem setRightBarButtonItem:switchToText];
    */
    NSString *destination =[NSString stringWithFormat:@"%f, %f", self.spotLat, self.spotLong];//@"950 De Guigne Dr, Sunnyvale, CA 94085@37.386888,-122.004564";
    
    //address without latlon
    
    
    
    NSString *title = @"Telenav HQ";
    
    NSString *token = @"fFWUlXmSdqNcCE2MBsexfEpB3hBl3Tv8n9ZmFpDWev1etAqujpLgIYfyhm5HK_ijJDQ2Qq2Z6F8V50HM_d1axaaMCIw6mm012fhCME9i5S0QJ64t_MF4Vq1itm6vVR7O5cV9FyvahgzF8EZc_2pA8qOGkBuf0K4GKZHQwR8UZm0";
    
    
    
    //make sure all parameters are URL encoded
    
    NSString *escapedUrlDestination = encodeToPercentEscapeString(destination);
    
    NSString *escapedUrlTitle = encodeToPercentEscapeString(title);
    
    NSString *escapedUrlToken = encodeToPercentEscapeString(token);
    
    
    
    NSString *endpoint = [NSString stringWithFormat: @"http://apps.scout.me/v1/driveto?dt=%@&title=%@&token=%@&name=Parkify", escapedUrlDestination, escapedUrlTitle, escapedUrlToken];
    currWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
    currWebView.delegate = self;
    currWebView.scalesPageToFit = YES;

    [self.view addSubview:currWebView];
    NSLog(@"The url is %@", endpoint);
    
    [currWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:endpoint]]];

	// Do any additional setup after loading the view.
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

-(void)getCenterCoord:(NSNumber *)ider{
    NSString *boolVals = @"0";
    if (textDirs)
        boolVals=@"1";
  //  [currWebView returnResult:[ider intValue] args:[NSNumber numberWithDouble:currLat], [NSNumber numberWithDouble:currLong], [NSNumber numberWithDouble:spotLat], [NSNumber numberWithDouble:spotLong], boolVals, nil];
}
-(void)finishedLoading{
    if(self.waitingMask) {
        [self.waitingMask removeFromSuperview];
        self.waitingMask = nil;
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
