//
//  ParkingSpotCollection.m
//  Parkify
//
//  Created by Me on 8/16/12.
//
//


#import "ParkingSpot.h"
#import "SBJSON.h"
#import "ASIHTTPRequest.h"
#import "Api.h"
#import "iToast.h"
#import "Persistance.h"
#import "ParkingSpotCollection.h"

@interface ParkingSpotCollection()

@end

@implementation ParkingSpotCollection


@synthesize parkingSpots = _parkingSpots;
@synthesize observerDelegate = _observerDelegate;
@synthesize currentSpot = _currentSpot;

- (NSDictionary*)parkingSpots {
    if(!_parkingSpots) _parkingSpots = [[NSDictionary alloc] init];
    return _parkingSpots;
}

- (ParkingSpot*)parkingSpotForID:(int)key {
    return [self.parkingSpots objectForKey:[[NSNumber alloc] initWithInt:key]];
}

- (id)initFromDictionary:(NSDictionary*)root {
    if ((self = [super init])) {
        [self updatefromDictionary:root];
    }
    return self;
}



- (void)updateWithRequest:(NSDictionary*)req {
    if([[req objectForKey:@"count"] isEqualToString: @"one"]) {
        [Api getParkingSpotWithID:[[req objectForKey:@"id"] intValue] withLevelofDetail:[req objectForKey:@"level_of_detail"] withSuccess:^(NSDictionary* root) {
            [self updatefromDictionary:root];
        } withFailure:^(NSError* error) {
            NSLog(@"Error: %@", error.localizedDescription);
            [[[iToast makeText:@"Loading..."] setGravity:iToastGravityBottom ] show];
        }];
    } else {
        [Api getParkingSpotsWithLevelofDetail:[req objectForKey:@"level_of_detail"] withSuccess:^(NSDictionary* root) {
            [self updatefromDictionary:root];
        } withFailure:^(NSError* error) {
            NSLog(@"Error: %@", error.localizedDescription);
            [[[iToast makeText:@"Loading..."] setGravity:iToastGravityBottom ] show];
        }];
    }
}


/*
 
 NSURL *url = [NSURL URLWithString:@"http://parkify-rails.herokuapp.com/api/v1/resources.json"];
 
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
 [[[iToast makeText:@"Loading..."] setGravity:iToastGravityBottom ] show];
 }];
 
 // 6
 [request startAsynchronous];
 }
 
 */
/*
 - (void)debugPopulate {
 #define NO_SERVICE_DEBUG_SPOTS @"[{\"mID\":\"3\",\"mLat\":37.872654\",\"mLong\":\"122.266812\",\"mCompanyName\":\"Mike\"s Bikes\",\"mLocalID\":\"3\",\"mPrice\":\"1.02\",\"mPhoneNumber\":\"408-421-1194\",\"mDesc\":\"A Fantastic Spot!\",\"mFree\":\"true\"}]"
 
 NSMutableDictionary *newParkingSpots = [[NSMutableDictionary alloc] init];
 
 int idIn = 3;
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
 */



- (void)updatefromDictionary:(NSDictionary*)root {
    
    double startTime = [Persistance retrieveCurrentStartTime];
    double endTime = [Persistance retrieveCurrentEndTime];
    int currentSpotId = [Persistance retrieveCurrentSpotId];
    
    double currentTime = [[NSDate date] timeIntervalSince1970];
    BOOL bInInterval = (currentTime >= startTime) && (currentTime <= endTime);
    
    NSMutableDictionary* newParkingSpots;
    
    NSString* count = [root objectForKey:@"count"];
    NSString* levelOfDetail = [root objectForKey:@"level_of_detail"];
    
    int idIn = -2;
    
    if ([count isEqualToString: @"one"]) {
        newParkingSpots = [self.parkingSpots mutableCopy];
        
        NSDictionary* spot = [root objectForKey:@"spot"];
        idIn = [[spot objectForKey:@"id"] intValue];
        
        ParkingSpot* actualSpot = [newParkingSpots objectForKey:[[NSNumber alloc] initWithInt:idIn]];
        BOOL bInCollection = (actualSpot != nil);
        if(!bInCollection) {
            actualSpot = [[ParkingSpot alloc] init];
        }
        
        if(bInInterval && (idIn == currentSpotId)) {
            self.currentSpot = actualSpot;
        }
        
        
        BOOL bFree = [actualSpot updateFromDictionary:spot withLevelOfDetail:levelOfDetail];
        
        if(!bFree) {
            if (bInCollection) {
                [newParkingSpots removeObjectForKey:[[NSNumber alloc] initWithInt:idIn]];
            } else {
                return;
            }
        } else {
            if (!bInCollection) {
                [newParkingSpots setObject:actualSpot forKey:[[NSNumber alloc] initWithInt:idIn]];
            }
        }
    } else {
        newParkingSpots = [[NSMutableDictionary alloc] init];
    
    
    //update everything
        for (NSDictionary * spot in [root objectForKey:@"spots"]) {
        
            int idIn = [[spot objectForKey:@"id"] intValue];
        
            ParkingSpot* actualSpot = [[ParkingSpot alloc] init];
            
            if(bInInterval && (idIn == currentSpotId)) {
                self.currentSpot = actualSpot;
            }
        
            BOOL bFree = [actualSpot updateFromDictionary:spot withLevelOfDetail:levelOfDetail];
        
            if(!bFree) {
                continue;
            }
        
            [newParkingSpots setObject:actualSpot forKey:[[NSNumber alloc] initWithInt:idIn]];
            actualSpot.parentCollection = self;
        }
    }

    self.parkingSpots = [newParkingSpots copy];

    if(self.observerDelegate)[self.observerDelegate spotsWereUpdatedWithCount:count withLevelOfDetail:levelOfDetail withSpot:(int)idIn];
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

- (double)distanceToClosestAvailableSpotToCoord:(CLLocationCoordinate2D)coord {
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
    return bestDistYet*0.000621371;
}




@end
