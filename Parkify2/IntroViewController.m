//
//  IntoViewController.m
//  Parkify
//
//  Created by Me on 1/31/13.
//
//

#import "IntroViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TestPage.h"
#import "DirectionsFlowing.h"
#import "IntroAboutPage.h"
#import "TrialAccountPage.h"
#import "Parkify2ViewController.h"
#import "Persistance.h"
#import "SBJson.h"
#import "AccountUpdatePage.h"

#define MARGIN_HORIZ 20
#define MARGIN_VERT 20

@interface IntroViewController ()
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *pageScrollView;

@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) NSMutableArray* pages;
@property (strong, nonatomic) TrialAccountPage* trialAccountPage;

-(IBAction)skipButtonTapped:(id)sender;
@end

@implementation IntroViewController

@synthesize keyboardAvoidingScrollView = _keyboardAvoidingScrollView;
@synthesize openedFromSettings = _openedFromSettings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.openedFromSettings = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.skipButton.alpha = 0;
    
    [self.pageScrollView setPagingEnabled:true];
    [self.pageScrollView setShowsHorizontalScrollIndicator:false ];
    [self.pageScrollView setBackgroundColor:[UIColor clearColor]];
    
    [self setupPages];
    [self displayPages];
    
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    if (sender == self.pageScrollView) {
        CGFloat pageWidth = self.pageScrollView.frame.size.width;
        int page = floor((self.pageScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
        
        
        double skipAlpha = (self.pageScrollView.contentOffset.x - pageWidth / 2) / pageWidth;
        skipAlpha +=  2.5;
        skipAlpha -= [self.pages count];
        skipAlpha = MAX(0, skipAlpha);
        skipAlpha = MIN(1, skipAlpha);
        self.skipButton.alpha = skipAlpha;
        
    }
}


- (void)displayPages {
    
    if (self.pages != NULL) {
        int pageCount = [self.pages count];
        if (pageCount != 0) {
            
            if(pageCount == 1) {
                [self.pageControl setHidden:true];
            }
            
            self.pageControl.numberOfPages = pageCount;
            self.pageControl.currentPage = 0;
            
            //Now generate each page.
            int i=0;
            for (UIControl<DirectionsFlowing>* page in self.pages) {
                CGRect frame = page.frame;
                frame.origin.x = self.pageScrollView.frame.size.width*i + MARGIN_HORIZ;
                frame.origin.y = 0 + MARGIN_VERT;
                page.frame = frame;
                [self.pageScrollView addSubview:page];
                i++;
            }
            
            [self.pageScrollView setContentSize:CGSizeMake(self.pageScrollView.frame.size.width*pageCount, self.pageScrollView.frame.size.height)];
            
            self.pageScrollView.delegate=self;
            
        }
    }
    
}


- (void) setupPages {
    
    /* Intro About Pages */
    NSArray* imageNames = [NSArray arrayWithObjects:@"screenshot_find_1.png",@"screenshot_reserve_1.png",@"screenshot_park_1.png", nil];
    NSArray* titles = [NSArray arrayWithObjects:@"LOCATE A PARKING SPOT",@"RESERVE YOUR SPOT",@"PARK... EFFORTLESSLY", nil];
    NSArray* subtitles = [NSArray arrayWithObjects:@"Near your location or a target destination",@"Select a duration and pay with your credit card",@"Using turn-by-turn directions and our photo-based navigation system", nil];
    
    self.pages = [[NSMutableArray alloc] init];
    CGRect frame = CGRectMake(0, 0, self.pageScrollView.frame.size.width - (2*MARGIN_HORIZ), self.pageScrollView.frame.size.height - (2*MARGIN_VERT));
    for (int i=0; i<[imageNames count]; i++) {
        IntroAboutPage* page = [[IntroAboutPage alloc] initWithFrame:frame withImageName:[imageNames objectAtIndex:i] withTitle:[titles objectAtIndex:i] withSubTitle:[subtitles objectAtIndex:i]];
        
        //page.layer.cornerRadius = 20;
        //page.layer.masksToBounds = YES;
        
        [self.pages addObject:page];
    }

    /*
    self.trialAccountPage = [[TrialAccountPage alloc] initWithFrame:frame];
    self.trialAccountPage.keyboardAvoidingScrollView = self.keyboardAvoidingScrollView;
    [self.trialAccountPage addTarget:self action:@selector(switchToMap) forControlEvents:ShouldContinueActionEvent];
    
    NSString* firstUse = [Persistance retrieveFirstUse];
    
    if([firstUse isEqualToString:@"true"]) {
        [self.trialAccountPage setStateTrialAccount];
    } else if ([firstUse isEqualToString:@"unset"]) {
        [self.trialAccountPage setStateWaiting];
    } else {
        [self.trialAccountPage setStatePassThrough];
    }
    
    [self.pages addObject:self.trialAccountPage];
    */
    
    
}

-(IBAction)skipButtonTapped:(id)sender {
    if(self.openedFromSettings) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    } else {
        [self switchToMap];
    }
}

-(void) switchToMap {
    // Create the root view controller for the navigation controller
    // The new view controller configures a Cancel and Done button for the
    // navigation bar.
    /*
    Parkify2ViewController *addController = [[Parkify2ViewController alloc]
                                              initWithNibName:@"Parkify2ViewController" bundle:nil ];
     */
    UIStoryboard *storyboard = self.storyboard;
    Parkify2ViewController *addController = [storyboard instantiateViewControllerWithIdentifier:@"MapVC"];
    
    
    // Create the navigation controller and present it.
    /*
     UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:addController];
    [self presentViewController:navigationController animated:YES completion: nil];
    */
    /*
    [self dismissViewControllerAnimated:true completion:^{
        [Persistance saveGotPastDemo:true];
    }]
    */
    [self presentViewController:addController animated:true completion:^{
        [Persistance saveGotPastDemo:true];
    }];
}



- (void)viewDidUnload {
    [self setSkipButton:nil];
    [super viewDidUnload];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    
    if(request.tag == kLoadUDIDandPush){
        NSDictionary * root = [responseString JSONValue];
        NSLog(@"Finished %@", responseString);
        
        BOOL success = [[root objectForKey:@"success"] boolValue];
        BOOL isNew = [[root objectForKey:@"isNew"] boolValue];
        if(success) {
            if(isNew) {
                [Persistance saveFirstUse:@"true"];
                if(self.trialAccountPage) {
                    [self.trialAccountPage setStateTrialAccount];
                }
            } else {
                [Persistance saveFirstUse:@"false"];
                if(self.trialAccountPage) {
                    [self.trialAccountPage setStatePassThrough];
                }
            }
        } else {
            NSLog(@"Failed ot save device %@", root);
            //Assume that device has exauhsted its trial account.
            [Persistance saveFirstUse:@"unset"];
            if(self.trialAccountPage) {
                [self.trialAccountPage setStatePassThrough];
            }
        }
    }
}
-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"Failed to register push token and udid!");
}


@end




