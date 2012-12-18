//
//  troubleFindingSpotViewController.m
//  Parkify
//
//  Created by gnamit on 11/8/12.
//
//

#import "troubleFindingSpotViewController.h"
#import "ExtraTypes.h"
#import "Api.h"
#import "ParkifyAppDelegate.h"
@interface troubleFindingSpotViewController ()

@end

@implementation troubleFindingSpotViewController
@synthesize theSpot= _theSpot;
@synthesize transactionInfo = _transactionInfo;
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
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [titleView setFont:[UIFont fontWithName:@"Helvetica Light" size:36.0f]];
    [titleView setTextColor:[UIColor colorWithRed:197.0f/255.0f green:211.0f/255.0f blue:247.0f/255.0f alpha:1.0f]];
    [titleView setText:@"Uh-oh!"];
    [titleView sizeToFit];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setTitleView:titleView];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex   {
    if (buttonIndex == alertView.cancelButtonIndex){
        [self dismissViewControllerAnimated:YES completion:^{

        }];

    }
}
- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)refundAndReturn:(id)sender {
    ParkifyAppDelegate *delegate  = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
    [Api sendProblemSpotWithText:@"Can't Find" andImage:NULL andResourceID:self.theSpot.actualID withLat:delegate.currentLat andLong:delegate.currentLong withAcceptanceID:[[self.transactionInfo objectForKey:@"acceptanceid"] intValue] shouldCancel:NO withASIHTTPDelegate:NULL];


    [[[UIAlertView alloc] initWithTitle:@"Refund" message:@"Your refund has been processed. Sorry about the problems!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    
}

- (IBAction)launchPhone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPhoneNumber]];

    }];

}

- (IBAction)launchDirections:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];

}
@end
