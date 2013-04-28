//
//  ParkingDirectionsPage.m
//  Parkify
//
//  Created by Me on 1/26/13.
//
//

#import "ParkingDirectionsPage.h"
#import "MultiImageViewer.h"
#import "SBJson.h"
#import "ParkifyAppDelegate.h"

#define ANNOTATION_MINI_WIDTH_ORIG 49
#define ANNOTATION_MINI_HEIGHT_ORIG 51

#define ANNOTATION_MINI_TIP_HORIZ 22

#define ANNOTATION_MINI_WIDTH (ANNOTATION_MINI_WIDTH_ORIG * 0.35)
#define ANNOTATION_MINI_HEIGHT (ANNOTATION_MINI_HEIGHT_ORIG * 0.35)
#define ANNOTATION_MINI_RELATIVE_HORIZ_OFFSET (-((ANNOTATION_MINI_WIDTH_ORIG/2.0)-ANNOTATION_MINI_TIP_HORIZ) * 0.35)



#define ANNOTATION_MINI_ARROW_WIDTH_ORIG 33
#define ANNOTATION_MINI_ARROW_HEIGHT_ORIG 33

#define ANNOTATION_MINI_ARROW_TIP_HORIZ 16.5

#define ANNOTATION_MINI_ARROW_WIDTH (ANNOTATION_MINI_WIDTH_ORIG * 0.35)
#define ANNOTATION_MINI_ARROW_HEIGHT (ANNOTATION_MINI_HEIGHT_ORIG * 0.35)
#define ANNOTATION_MINI_ARROW_RELATIVE_HORIZ_OFFSET (-((ANNOTATION_MINI_ARROW_WIDTH_ORIG/2.0)-ANNOTATION_MINI_ARROW_TIP_HORIZ) * 0.35)

#define ZOOM_MARGIN_FACTOR_MINI 1.4


@interface ParkingDirectionsPage()


@property CLLocationCoordinate2D location;
@property double heading;
@property (strong, nonatomic) NSString* text;
@property int imageID;

@property (strong, nonatomic) MKMapView* mapView;


@end

@implementation ParkingDirectionsPage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withSpot:(ParkingSpot *)spot withReservation:(Acceptance *)reservation withIndex:(int)index withTotalIndex:(int)totalIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        self.spot = spot;
        self.reservation = reservation;
        self.index = index;
        self.totalIndex = totalIndex;
        
        self.imageID = -1;
        
        if(![self parseDirections]) {
            return self;
        }
        
        
        UIView* container = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x + 5, frame.origin.y + 5, frame.size.width - 10, frame.size.height - 10)];
        
        container.layer.cornerRadius = 4;
        container.clipsToBounds = YES;
        container.layer.borderColor = [UIColor blackColor].CGColor;
        container.layer.borderWidth = 2.0f;
        [self addSubview:container];
        
        double width = container.frame.size.width;
        double ySoFar = 0;
        
        CGRect imageFrame = CGRectMake(0,0,width,width*(2.0/3.0));
        
        if(self.imageID > 0) {            
            MultiImageViewer* mainImage = [[MultiImageViewer alloc] initWithFrame:imageFrame withImageIds:[NSArray arrayWithObject:[NSNumber numberWithInt:self.imageID ]]];
            //mainImage.layer.borderColor = [UIColor blackColor].CGColor;
            //mainImage.layer.borderWidth = 2.0f;
            [container addSubview:mainImage];
        } else {
        }
        ySoFar += imageFrame.size.height;
        
        NSString* indexText = [NSString stringWithFormat:@"%d/%d", self.index+1, self.totalIndex];
        CGSize labelSize = [indexText sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:28]];
        UILabel* indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,labelSize.width+2,labelSize.height)];
        indexLabel.text = indexText;
        indexLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
        indexLabel.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
        indexLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        indexLabel.textAlignment = UITextAlignmentCenter;
        
        
        
        UIImageView* textBarBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, ySoFar, width, 50)];
        //textBarBackground.image = [UIImage imageNamed:@"direction_bar.png"];
        textBarBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stressed_linen.png"]];
        textBarBackground.layer.borderColor = [UIColor blackColor].CGColor;
        textBarBackground.layer.borderWidth = 2.0f;
        
        
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(42,2,textBarBackground.frame.size.width-(42*2),textBarBackground.frame.size.height-4)];
        [textLabel setNumberOfLines:3];
        [textLabel setAdjustsFontSizeToFitWidth:true];
        [textLabel setMinimumFontSize:9];
        textLabel.text = self.text;
        textLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        textLabel.textAlignment = UITextAlignmentLeft;
        textLabel.backgroundColor = [UIColor clearColor];
        
        
        UILabel* swipeLeft = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 28, textBarBackground.frame.size.height)];
        swipeLeft.numberOfLines = 2;
        swipeLeft.text = (self.index <= 0) ? @"" : @"swipe left";
        swipeLeft.textColor = PARKIFY_CYAN;
        swipeLeft.lineBreakMode = UILineBreakModeWordWrap;
        swipeLeft.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:8];
        swipeLeft.minimumFontSize = 0;
        swipeLeft.backgroundColor = [UIColor clearColor];
        
        UILabel* swipeRight = [[UILabel alloc] initWithFrame:CGRectMake(textBarBackground.frame.size.width-31, 0, 28, textBarBackground.frame.size.height)];
        swipeRight.numberOfLines = 2;
        swipeRight.text = (self.index+1 >= self.totalIndex) ? @"" : @"swipe right";
        swipeRight.textColor = PARKIFY_CYAN;
        swipeRight.lineBreakMode = UILineBreakModeWordWrap;
        swipeRight.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:8];
        swipeRight.minimumFontSize = 0;
        swipeRight.backgroundColor = [UIColor clearColor];
        swipeRight.textAlignment = UITextAlignmentRight;
        
        
        
        UIButton* leftChevron = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, textBarBackground.frame.size.height)];
        
        NSString* leftImage = (self.index <= 0) ? @"chevron_unactive_left.png" : @"chevron_active_left.png";
        [leftChevron setImage:[UIImage imageNamed:leftImage] forState:UIControlStateNormal];
        
        UIButton* rightChevron = [[UIButton alloc] initWithFrame:CGRectMake(textBarBackground.frame.size.width-42, 0, 42, textBarBackground.frame.size.height)];
        NSString* rightImage = (self.index+1 >= self.totalIndex) ? @"chevron_unactive_right.png" : @"chevron_active_right.png";
        [rightChevron setImage:[UIImage imageNamed:rightImage] forState:UIControlStateNormal];
        
        
        
        //mapView
        ySoFar += textBarBackground.frame.size.height;
        
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, ySoFar, width, frame.size.height - ySoFar)];
        [self.mapView setDelegate:self];
        //self.mapView.layer.borderColor = [UIColor blackColor].CGColor;
        //self.mapView.layer.borderWidth = 2.0f;
        [self.mapView setShowsUserLocation:true];
        [self.mapView addAnnotation:[ParkingSpotAnnotation annotationForSpot:self.spot]];
        [self.mapView setUserInteractionEnabled:false];
        
        DirectionAnnotation* annotation = [[DirectionAnnotation alloc] init];
        annotation.coordinate = self.location;
        annotation.heading = self.heading;
        
        [self.mapView addAnnotation:annotation];
        
        
        UIView* mapCover = [[UIView alloc] initWithFrame:self.mapView.frame];
        mapCover.alpha = 0;
        [mapCover setUserInteractionEnabled:true];
        
        //now add them in the right order
        
        [container addSubview: self.mapView];
        [container addSubview: mapCover];
        
        [container addSubview:indexLabel];
        
        [container addSubview:textBarBackground];
        [textBarBackground addSubview:textLabel];
        /*
        [textBarBackground addSubview:leftChevron];
        [textBarBackground addSubview:rightChevron];
         */
        [textBarBackground addSubview:swipeLeft];
        [textBarBackground addSubview:swipeRight];
        ParkifyAppDelegate *delegate = (ParkifyAppDelegate*)[[UIApplication sharedApplication] delegate];
        [self userAt:CLLocationCoordinate2DMake(delegate.currentLat, delegate.currentLong)];
    }
    return self;
}

- (BOOL)parseDirections {
    NSDictionary* directions = [self.spot.mDirections JSONValue];
    
    NSArray* sources = [directions objectForKey:@"sources"];
    if(!sources || [sources count] <= 0) {
        return false;
    }
    NSArray* source = [sources objectAtIndex:0];
    
    
    if(!source || [source count] <= self.index) {
        return false;
    }
    
    NSDictionary* dirNode = [source objectAtIndex:self.index];
    if(!dirNode) {
        return false;
    }
    
    /* success */
    
    NSDictionary* location = [dirNode objectForKey:@"location"];
    if(location) {
        NSNumber* latitude = [location objectForKey:@"lat"];
        NSNumber* longitude = [location objectForKey:@"long"];
        if (latitude != NULL && longitude != NULL) {
            self.location = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        }
    }
    
    NSNumber* heading = [dirNode objectForKey:@"heading"];
    if(heading != NULL) {
        self.heading = [heading doubleValue];
    }
    
    NSArray* conds = [dirNode objectForKey:@"conds"];
    if(conds && [conds count] > 0) {
        NSDictionary* cond = [conds objectAtIndex:0];
        if(cond) {
            NSString* text = [cond objectForKey:@"text"];
            if(text) {
                self.text = text;
            }
            NSString* imageName = [cond objectForKey:@"image"];
            if(imageName) {
                int imageId = [self.spot idForName:imageName];
                if(imageId > 0) {
                    self.imageID = imageId;
                }
            }
            
        }
    }
    
    return true;
}

- (void)moreToLeft:(BOOL)isMore {
    
}
- (void)moreToRight:(BOOL)isMore {
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier;
        
    if ([annotation isKindOfClass:[ParkingSpotAnnotation class]]) {
        
        ParkingSpot* spot = ((ParkingSpotAnnotation*)annotation).spot;
        
        identifier = spot.mSpotType;
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.canShowCallout = NO;
            annotationView.enabled = true;
        }
        
        annotationView.annotation = annotation;
        
        annotationView.image = [UIImage imageNamed:@"blue_pin_mini.png"];
        
        
        CGRect frame = annotationView.frame;
        frame.size.width = ANNOTATION_MINI_WIDTH;
        frame.size.height = ANNOTATION_MINI_HEIGHT;
        annotationView.frame = frame;
        annotationView.centerOffset = CGPointMake(ANNOTATION_MINI_RELATIVE_HORIZ_OFFSET, -annotationView.frame.size.height/2);
        
        return annotationView;
    } else if ([annotation isKindOfClass:[DirectionAnnotation class]]) {
        identifier = @"direction";
        MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.canShowCallout = NO;
            annotationView.enabled = true;
        }
        
        annotationView.annotation = annotation;
        
        annotationView.image = [UIImage imageNamed:@"arrow_right_mini.png"];
        
        
        CGRect frame = annotationView.frame;
        frame.size.width = ANNOTATION_MINI_ARROW_WIDTH;
        frame.size.height = ANNOTATION_MINI_ARROW_HEIGHT;
        annotationView.frame = frame;
        
        
        //annotationView.centerOffset = 
        
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(-self.heading);
        
        
        
        
        CGPoint origCenterOffset = CGPointMake(0, ANNOTATION_MINI_RELATIVE_HORIZ_OFFSET);
        CGPoint transformedCenterOffset = CGPointApplyAffineTransform(origCenterOffset,transform);
        annotationView.centerOffset = transformedCenterOffset;
        
        annotationView.layer.anchorPoint = CGPointMake(1.0,0.5);
        annotationView.transform = transform;
        return annotationView;
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self userAt:newLocation.coordinate];
}

- (void) userAt:(CLLocationCoordinate2D )location {
    
    double minLat = MIN(location.latitude, MIN(self.location.latitude, self.spot.mLat));
    double minLong = MIN(location.longitude, MIN(self.location.longitude, self.spot.mLong));
    double maxLat = MAX(location.latitude, MAX(self.location.latitude, self.spot.mLat));
    double maxLong = MAX(location.longitude, MAX(self.location.longitude, self.spot.mLong));
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat+minLat)/2.0, (maxLong+minLong)/2.0);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(fabsf(maxLat-minLat)*ZOOM_MARGIN_FACTOR_MINI, fabsf(maxLong-minLong)*ZOOM_MARGIN_FACTOR_MINI);
    [self.mapView setRegion:MKCoordinateRegionMake(center, span) animated:true];
    
}

@end


@implementation DirectionAnnotation

@synthesize coordinate = _coordinate;

@synthesize heading = _heading;

@end