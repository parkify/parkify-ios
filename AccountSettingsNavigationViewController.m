//
//  AccountSettingsNavigationViewController.m
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import "AccountSettingsNavigationViewController.h"

@interface AccountSettingsNavigationViewController ()

@end

@implementation AccountSettingsNavigationViewController
@synthesize user = _user;

-(User*) user {
  ;
  return _user;
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
