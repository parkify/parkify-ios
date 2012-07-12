//
//  ParkingSpot.m
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkingSpot.h"
#import "SBJSON.h"
#import "ASIHTTPRequest.h"

@interface ParkingSpotCollection()

@end

@implementation ParkingSpotCollection


@synthesize parkingSpots = _parkingSpots;
@synthesize observerDelegate = _observerDelegate;

- (NSDictionary*)parkingSpots {
    if(!_parkingSpots) _parkingSpots = [[NSDictionary alloc] init];
    return _parkingSpots;
}

- (ParkingSpot*)parkingSpotForID:(int)key {
    return [self.parkingSpots objectForKey:[[NSNumber alloc] initWithInt:key]];
}

- (id)initFromJSONString:(NSString*)strJson {
    if ((self = [super init])) {
        [self updateFromJSONString:strJson];
    }
    return self;
}

- (void)updateWithRequest:(id)Request {
    NSURL *url = [NSURL URLWithString:@"http://swooplot.herokuapp.com/parking_spots"];
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"GET";    
    
    [request setDelegate:self];
    [request setCompletionBlock:^{         
        NSString *responseString = [request responseString];
        [self updateFromJSONString:responseString];
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    // 6
    [request startAsynchronous];

}

- (void)updateFromJSONString:(NSString*)strJson {
    NSMutableDictionary *newParkingSpots = [[NSMutableDictionary alloc] init];
    NSDictionary * root = [strJson JSONValue];
    
    for (NSDictionary * spot in root) {
        
        int idIn = [[spot objectForKey:@"mID"] intValue];
        double latIn = [[spot objectForKey:@"mLat"] doubleValue];
        double lngIn = [[spot objectForKey:@"mLong"] doubleValue];
        NSString * companyNameIn = [spot objectForKey:@"mCompanyName"];
        int localIDIn = [[spot objectForKey:@"mLocalID"] intValue];
        double priceIn = [[spot objectForKey:@"mPrice"] doubleValue];
        NSString * phoneNumberIn = [spot objectForKey:@"mPhoneNumber"];
        NSString * descIn = [spot objectForKey:@"mDesc"];
        Boolean freeIn = [[spot objectForKey:@"mFree"] boolValue];
        
        ParkingSpot *spotActual = [[ParkingSpot alloc] initWithID:idIn 
                                                              lat:latIn
                                                              lng:lngIn 
                                                      companyName:companyNameIn
                                                          localID:localIDIn 
                                                            price:priceIn
                                                      phoneNumber:phoneNumberIn 
                                                             desc:descIn
                                                             free:freeIn];    
        [newParkingSpots setObject:spotActual forKey:[[NSNumber alloc] initWithInt:idIn]];    
    }
    for (id key in [newParkingSpots allKeys]) {
        ParkingSpot* pot = [newParkingSpots objectForKey:key];
        //NSLog(@"key: %@, value: %@\n", key, pot);
    }
    
    self.parkingSpots = [newParkingSpots copy];
    if(self.observerDelegate)[self.observerDelegate spotsWereUpdated];
}

-(CLLocation*) locFromCoord:(CLLocationCoordinate2D)coord {
    return [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
}

-(double) distFromA:(CLLocationCoordinate2D)a toB:(CLLocationCoordinate2D)b {
    return [[self locFromCoord:a] distanceFromLocation:[self locFromCoord:b]];
}

- (ParkingSpot*)closestAvailableSpotToCoord:(CLLocationCoordinate2D)coord {
    ParkingSpot* bestSpotYet = nil;
    double bestDistYet = 1000000000000;
    for ( ParkingSpot* spot in [self.parkingSpots allValues]) {
        if (spot.mFree) {
            CLLocationCoordinate2D spotCoord;
            spotCoord.latitude = spot.mLat;
            spotCoord.longitude = spot.mLong;
        
            double thisDist = [self distFromA:spotCoord toB:coord];
            if (thisDist < bestDistYet) {
                bestDistYet = thisDist;
                bestSpotYet = spot;
            }
        }
    }
    return bestSpotYet;
}



@end


@interface ParkingSpot()

- (id)initWithID:(int)idIn lat:(double)latIn
             lng:(double)lngIn companyName:(NSString*)companyNameIn
         localID:(int)localIDIn price:(double)priceIn
     phoneNumber:(NSString*)phoneNumberIn desc:(NSString*)descIn
            free:(Boolean)freeIn;


@end

@implementation ParkingSpot
@synthesize mID = _mID;
@synthesize mLat = _mLat;
@synthesize mLong = _mLong;
@synthesize mCompanyName = _mCompanyName;
@synthesize mLocalID = _mLocalID;
@synthesize mPrice = _mPrice;
@synthesize mPhoneNumber= _mPhoneNumber;
@synthesize mDesc = _mDesc;
@synthesize mFree = _mFree;
@synthesize mRemove = _mRemove;

- (id)initWithID:(int)idIn lat:(double)latIn
             lng:(double)lngIn companyName:(NSString*)companyNameIn
         localID:(int)localIDIn price:(double)priceIn
     phoneNumber:(NSString*)phoneNumberIn desc:(NSString*)descIn
            free:(Boolean)freeIn {	
    if ((self = [super init])) {
        self.mID = idIn;
        self.mLat = latIn;
        self.mLong = lngIn;
        self.mCompanyName = [companyNameIn copy];
        self.mLocalID = localIDIn;
        self.mPrice = priceIn;
        self.mPhoneNumber = [phoneNumberIn copy];
        self.mDesc = [descIn copy];
        self.mFree = freeIn;
        self.mRemove = false;
        //_coordinate.latitude = latIn;
        //_coordinate.longitude = lngIn;
    }
    return self;
}
@end

@implementation ParkingSpotAnnotation

@synthesize spot = _spot;

+ (ParkingSpotAnnotation *)annotationForSpot:(ParkingSpot*)spot {
    ParkingSpotAnnotation * annotation = [[ParkingSpotAnnotation alloc] init];
    annotation.spot = spot;
    return annotation;
}

- (CLLocationCoordinate2D) coordinate {
    CLLocationCoordinate2D coordToRtn;
    coordToRtn.latitude = self.spot.mLat;
    coordToRtn.longitude = self.spot.mLong;
    return coordToRtn;
}
- (NSString *)title {
    return [NSString stringWithFormat:@"%@ %d | %0.2f/hr", 
            self.spot.mCompanyName, self.spot.mLocalID, self.spot.mPrice];
}
- (NSString *)subtitle {
    return [NSString stringWithFormat:@"%@ to Book", self.spot.mPhoneNumber];
}

- (BOOL)updateAnnotationWith:(id)annotation onlyifIDsAreSame:(BOOL)boolIDsSame
{
    if (![annotation isKindOfClass:[ParkingSpotAnnotation class]]) {
        return false;
    }
    if(!boolIDsSame || ((ParkingSpotAnnotation*)annotation).spot.mID == self.spot.mID) {
        [self willChangeValueForKey:@"coordinate"];
        [self willChangeValueForKey:@"title"];
        [self willChangeValueForKey:@"subtitle"];
        self.spot = ((ParkingSpotAnnotation*)annotation).spot;
        [self didChangeValueForKey:@"subtitle"];
        [self didChangeValueForKey:@"title"];
        [self didChangeValueForKey:@"coordinate"];
        return true;
    }
    return false;
}

@end
