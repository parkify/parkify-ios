//
//  ParkifyWebViewWrapperController.m
//  Parkify
//
//  Created by Me on 9/9/12.
//
//

#import "ParkifyWebViewWrapperController.h"
//#import "PlacedAgent.h"

@interface ParkifyWebViewWrapperController ()

@end

@implementation ParkifyWebViewWrapperController

@synthesize viewWeb = _viewWeb;
@synthesize url = _url;

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
    
    //[PlacedAgent logPageView:@"WebWrapperView"];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@?view=iphone", self.url];

    
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.viewWeb loadRequest:requestObj];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setViewWeb:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender {
    [self dismissModalViewControllerAnimated:true];
}

- (IBAction)callParkify:(UIButton *)sender {
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        UIAlertView *Permitted=[[UIAlertView alloc] initWithTitle:@"Need Help?" message:@"Would you like to call Parkify?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [Permitted show];
    } else {
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"No"])
    {
        //NSLog(@"Button 1 was selected.");
    }
    else if([title isEqualToString:@"Yes"])
    {
        //NSLog(@"Button 2 was selected.");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:1-855-727-5439"]]];
    }
}
@end
