//
//  DirecionsViewController.m
//  Parkify
//
//  Created by Me on 8/11/12.
//
//

#import "DirecionsViewController.h"

@interface DirecionsViewController ()

@end

@implementation DirecionsViewController

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
	// Do any additional setup after loading the view.
    
    //CLLocationCoordinate2D currentLocation = [self getCurrentLocation];
    
    NSString* address = @"123 Main St., New York, NY, 10001";
    NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",
                     37.0,-122.0,//currentLocation.latitude, currentLocation.longitude,
                     [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
