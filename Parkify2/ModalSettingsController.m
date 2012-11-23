//
//  ModalSettingsController.m
//  Parkify2
//
//  Created by Me on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModalSettingsController.h"

@interface ModalSettingsController ()

@end

@implementation ModalSettingsController

@synthesize successBlock = _successBlock;

- (SuccessBlock)successBlock {
    if(!_successBlock) {
        _successBlock = ^(NSDictionary* results){};
    }
    return _successBlock;
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) exitWithResults:(NSDictionary *)results {
    [self dismissViewControllerAnimated:true completion:^{ self.successBlock(results); }
     ];
}

@end
