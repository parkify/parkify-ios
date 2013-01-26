//
//  DirectionsScrollView.m
//  Parkify
//
//  Created by Me on 1/24/13.
//
//

#import "DirectionsScrollView.h"
#import "Api.h"
#import "TestPage.h"
#import "DrivingDirectionsPage.h"
#import "ParkingDirectionsPage.h"
#import "ConfirmationPage.h"
#import "SBJson.h"

#define PAGE_CONTROL_VERT_OFFSET (-20)
#define PAGE_CONTROL_HORIZ_OFFSET 0


@interface DirectionsScrollView()

@property (strong, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *parkingPageScrollView;
@end

@implementation DirectionsScrollView

@synthesize drivingDirectionsPage = _drivingDirectionsPage;
@synthesize parkingDirectionsPages = _parkingDirectionsPages;
@synthesize confirmationPage = _confirmationPage;
@synthesize currentParkingDirectionsPage = _currentParkingDirectionsPage;
@synthesize currentDirectionsGroup = _currentDirectionsGroup;
@synthesize parkingPageScrollView = _parkingPageScrollView;

@synthesize reservation = _reservation;
@synthesize spot = _spot;


//I RECCOMMEND YOU DONT USE THIS
/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}
*/
- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame withSpot:(ParkingSpot *)spot withReservation:(Acceptance *)reservation
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.spot = spot;
        self.reservation = reservation;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect relRect = frame;
    relRect.origin = CGPointMake(0,0);
    
    self.pageScrollView = [[UIScrollView alloc] initWithFrame:relRect];
    [self.pageScrollView setScrollEnabled:false];
    [self.pageScrollView setShowsHorizontalScrollIndicator:false ];
    [self.pageScrollView setBackgroundColor:[UIColor clearColor]];
    //[self.pageScrollView setUserInteractionEnabled:true];
    [self.pageScrollView setDelegate:self];
    [self addSubview:self.pageScrollView];
    
    
    
    
    
    self.currentDirectionsGroup = 0;
    self.currentParkingDirectionsPage = 0;
    
    
    /*
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.center = CGPointMake( PAGE_CONTROL_HORIZ_OFFSET + frame.size.width/2.0, frame.size.height + PAGE_CONTROL_VERT_OFFSET);
     
    
    [self addSubview:self.pageControl];
     */
    
    [self addAllPages];
        
    }
    return self;
}

- (void) generatePageContent {
    
    /* Driving Directions Page */
    DrivingDirectionsPage* drivingDirectionsPage=[[DrivingDirectionsPage alloc] initWithFrame:CGRectMake(0, 0, self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height) withSpot:self.spot withReservation:self.reservation ];
                                                  
    self.drivingDirectionsPage = drivingDirectionsPage;
    
    
    /* Parking Directions Pages */
    CGRect relRect = self.pageScrollView.frame;
    relRect.origin = CGPointMake(0,0);
    
    self.parkingPageScrollView = [[UIScrollView alloc] initWithFrame:relRect];
    [self.parkingPageScrollView setPagingEnabled:true];
    [self.parkingPageScrollView setShowsHorizontalScrollIndicator:false ];
    [self.parkingPageScrollView setBackgroundColor:[UIColor clearColor]];
    [self.parkingPageScrollView setDelegate:self];
    
    int totalParkingDirectionsPages = [self totalParkingDirectionsPages];
    
    self.parkingDirectionsPages = [[NSMutableArray alloc] init];
    if(totalParkingDirectionsPages == 0) {
        TestPage* filler=[[TestPage alloc]initWithFrame:CGRectMake(0, 0, self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height)];
        filler.label.text = @"No Parking Directions";
        [self.parkingDirectionsPages addObject:filler];
    } else {
        for(int i=0; i<totalParkingDirectionsPages; i++) {
            ParkingDirectionsPage* parkingDirectionsPage=[[ParkingDirectionsPage alloc] initWithFrame:CGRectMake(0, 0, self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height) withSpot:self.spot withReservation:self.reservation withIndex:i withTotalIndex:totalParkingDirectionsPages];
            [self.parkingDirectionsPages addObject:parkingDirectionsPage];
        }
    }
    /* Confirmation Page */
    ConfirmationPage* confirmationPage=[[ConfirmationPage alloc]initWithFrame:CGRectMake(0, 0, self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height) withSpot:self.spot withReservation:self.reservation];
    self.confirmationPage = confirmationPage;
}

//TODO: make more general possibly.
- (void)addAllPages {
    
    [self generatePageContent];
    
    int marginHoriz = 0;//5;
    int marginVert = 0;//2;
    
    int pageCount = 6; //[self.parkingDirectionsPages count] + 2;
    
    int i = 0;
    
    
    /* Driving Directions Page */
    CGRect frame = self.drivingDirectionsPage.frame;
    frame.origin.x = (self.pageScrollView.frame.size.width)*i;
    frame.origin.y = 0;
    self.drivingDirectionsPage.frame = frame;
    [self.pageScrollView addSubview:self.drivingDirectionsPage];
    i++;

    
    /* Parking Directions Pages */
    frame = self.parkingPageScrollView.frame;
    frame.origin.x = (self.pageScrollView.frame.size.width)*i;
    frame.origin.y = 0;
    self.parkingPageScrollView.frame = frame;
    [self.pageScrollView addSubview:self.parkingPageScrollView];
    
    
    int j = 0;
    for(UIView<DirectionsFlowing>* page in self.parkingDirectionsPages) {
        CGRect frame = page.frame;
        frame.origin.x = (self.parkingPageScrollView.frame.size.width)*j;
        frame.origin.y = 0;
        page.frame = frame;
        [self.parkingPageScrollView addSubview:page];
        j++;
    }
    
    [self.parkingPageScrollView setContentSize:CGSizeMake(self.self.parkingPageScrollView.frame.size.width*j, self.self.parkingPageScrollView.frame.size.height)];
    
    i++;
    
    /* Confirmation Page */
    frame = self.confirmationPage.frame;
    frame.origin.x = (self.pageScrollView.frame.size.width)*i;
    frame.origin.y = 0;
    self.confirmationPage.frame = frame;
    [self.confirmationPage addTarget:self action:@selector(extendReservation) forControlEvents:
     ExtendReservationRequestedActionEvent];
    [self.pageScrollView addSubview:self.confirmationPage];
    i++;
    
    
    
    [self.pageScrollView setContentSize:CGSizeMake(self.pageScrollView.frame.size.width*i, self.pageScrollView.frame.size.height)];
    
    /* Parking Directions Pages */
    /*
    for (int i=0
            for (int i=0; i<pageCount; i++) {
                UIView* sub=[[UIView alloc]initWithFrame:CGRectMake(self.pictureScrollView.frame.size.width*i, 0, self.pictureScrollView.frame.size.width, self.pictureScrollView.frame.size.height)];
                
                //UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(10, 200, 100, 100)];
                
                //lab.text=@"scrollview";
                
                UIImageView *imagev=[[UIImageView alloc]initWithFrame:CGRectMake(marginHoriz, marginVert, sub.frame.size.width-2*marginHoriz, sub.frame.size.height-2*marginVert)];
                [imagev setContentMode:UIViewContentModeScaleAspectFit];
                
                
                int imageID = [[self.imageIDs objectAtIndex:i] intValue];
                
                UIActivityIndicatorView* pictureActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                pictureActivityView.center = sub.center;
                //CGRect frame = pictureActivityView.frame;
                //frame.origin.x = sub.frame.origin.x + 0.5* sub.frame.size.width
                
                [sub addSubview:imagev];
                [sub addSubview:pictureActivityView];
                [pictureActivityView startAnimating];
                
                [self addPictureWithID:imageID withImageView:imagev withActivityView:pictureActivityView];
                
                [self.pictureScrollView addSubview:sub];
                
            }
            
            [self.pictureScrollView setContentSize:CGSizeMake(self.pictureScrollView.frame.size.width*imgCount, self.pictureScrollView.frame.size.height)];
            
            self.pictureScrollView.delegate=self;
            
            
            
        }
    }
     */
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    /*
    if (self.currentDirectionsGroup == 1) {
        CGFloat pageWidth = self.pageScrollView.frame.size.width;
        int page = floor((self.pageScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        page = page - 1;
        if (page >=0 && page < [self.parkingDirectionsPages count]) {
            self.currentParkingDirectionsPage = page;
        }
        
        
     // clamp to this group
        
        CGPoint offset = self.pageScrollView.contentOffset;
        
        double minOffsetX = self.pageScrollView.frame.size.width;
        double maxOffsetX = self.pageScrollView.frame.size.width * [self.parkingDirectionsPages count];
        
        // Check if current offset is within limit and adjust if it is not
        if (offset.x < minOffsetX) {
            offset.x = minOffsetX;
            [self.pageScrollView setContentOffset:offset animated:false];
            //self.pageScrollView.contentOffset = offset;
        }
        if (offset.x > maxOffsetX) {
            offset.x = maxOffsetX;
            [self.pageScrollView setContentOffset:offset animated:false];
            //self.pageScrollView.contentOffset = offset;
        }
        
    }
*/
    
    
}
/*
- (void)setPageGroup:(int)group {
    float x = 0;
    self.currentDirectionsGroup = group;
    switch (group) {
        case 0:
            [self.pageScrollView setScrollEnabled:false];
             x = 0;
            break;
        case 1:
            [self.pageScrollView setScrollEnabled:true];
            x = self.pageScrollView.frame.size.width * (self.currentParkingDirectionsPage+ 1);
            break;
        case 2:
            [self.pageScrollView setScrollEnabled:false];
            x = self.pageScrollView.frame.size.width * ([self.parkingDirectionsPages count] + 1);
            break;
        default:
            break;
    }
    [self.pageScrollView setContentOffset:CGPointMake(x, 0) animated:true];
}
*/

- (int) totalParkingDirectionsPages {
    NSDictionary* directions = [self.spot.mDirections JSONValue];
    
    NSArray* sources = [directions objectForKey:@"sources"];
    if(!sources || [sources count] <= 0) {
        return 0;
    }
    NSArray* source = [sources objectAtIndex:0];
    
    if(!source) {
        return 0;
    }
    return [source count];
}

- (void)extendReservation {
    [self sendActionsForControlEvents:
     ExtendReservationRequestedActionEvent];
}

- (void)setPageGroup:(int)group {
    float x = self.pageScrollView.frame.size.width * group;
    self.currentDirectionsGroup = group;
    [self.pageScrollView setContentOffset:CGPointMake(x, 0) animated:true];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (self.parkingDirectionsPages) {
        for(ParkingDirectionsPage* page in self.parkingDirectionsPages) {
            [page locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
        }
    }
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
