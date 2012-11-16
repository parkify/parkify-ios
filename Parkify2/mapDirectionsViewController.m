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
    [currWebView reloadPage];
    NSString *buttontext = @"Map";
    if(!textDirs){
        buttontext=@"Text";
    }
    CGRect waitingMaskFrame = self.view.frame;
    waitingMaskFrame.origin.x = 0;
    waitingMaskFrame.origin.y = 0;
    
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];

    UIBarButtonItem *switchToText = [[UIBarButtonItem alloc] initWithTitle:buttontext style:UIBarButtonItemStyleBordered target:self action:@selector(switchDirs)];
    [self.navigationItem setRightBarButtonItem:switchToText];

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
    currWebView = [[MyWebView alloc] initWithFrame:self.view.frame];
    currWebView.customdelegate=self;
    [self.view addSubview:currWebView];
    self.waitingMask = [[WaitingMask alloc] initWithFrame:waitingMaskFrame];
    [self.view addSubview:self.waitingMask];

    textDirs=FALSE;
    UIBarButtonItem *switchToText = [[UIBarButtonItem alloc] initWithTitle:@"Text" style:UIBarButtonItemStyleBordered target:self action:@selector(switchDirs)];
    [self.navigationItem setRightBarButtonItem:switchToText];
	// Do any additional setup after loading the view.
}
-(void)getCenterCoord:(NSNumber *)ider{
    NSString *boolVals = @"0";
    if (textDirs)
        boolVals=@"1";
    [currWebView returnResult:[ider intValue] args:[NSNumber numberWithDouble:currLat], [NSNumber numberWithDouble:currLong], [NSNumber numberWithDouble:spotLat], [NSNumber numberWithDouble:spotLong], boolVals, nil];
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
