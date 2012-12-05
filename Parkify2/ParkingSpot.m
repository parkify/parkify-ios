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
#import "Api.h"
#import "iToast.h"
#import "ParkingSpotCollection.h"
#import "TextFormatter.h"

@implementation ParkingSpot

@synthesize parentCollection = _parentCollection;

@synthesize mID = _mID;
@synthesize mLat = _mLat;
@synthesize mLong = _mLong;

@synthesize mLocationName = _mLocationName;
@synthesize mSpotName = _mSpotName;

@synthesize imageIDs = _imageIDs;
@synthesize landscapeInfoImageIDs = _landscapeInfoImageIDs;
@synthesize landscapeConfImageIDs = _landscapeConfImageIDs;
@synthesize standardImageIDs = _standardImageIDs;

@synthesize mDesc = _mDesc;
@synthesize mFree = _mFree;
@synthesize mRemove = _mRemove;

@synthesize mSpotLayout = _mSpotLayout;
@synthesize mSpotDifficulty = _mSpotDifficulty;
@synthesize mSpotCoverage = _mSpotCoverage;
@synthesize mSpotSignage = _mSpotSignage;
@synthesize mSpotType = _mSpotType;

@synthesize mAddress = _mAddress;
@synthesize mDirections = _mDirections;

@synthesize offers = _offers;

- (id)initWithID:(int)idIn lat:(double)latIn
             lng:(double)lngIn locationName:(NSString*)locationNameIn
        spotName:(NSString*)spotNameIn
            free:(Boolean)freeIn
        spotType:(NSString*)spotTypeIn
       imageIDs:(NSArray*)imageIDsIn

      spotLayout:(NSString*)spotLayoutIn
  spotDifficulty:(NSString*)spotDifficultyIn
    spotCoverage:(NSString*)spotCoverageIn
     spotSignage:(NSString*)spotSignageIn {
    
    
    if ((self = [super init])) {
        self.mID = idIn;
        self.mLat = latIn;
        self.mLong = lngIn;
        self.mLocationName = [locationNameIn copy];
        self.mSpotName = [spotNameIn copy];
        self.mFree = freeIn;
        self.mRemove = false;
        self.imageIDs = [imageIDsIn copy];
        self.mSpotLayout = [spotLayoutIn copy];
        self.mSpotDifficulty = [spotDifficultyIn copy];
        self.mSpotCoverage = [spotCoverageIn copy];
        self.mSpotSignage = [spotSignageIn copy];
        self.mSpotType = [spotTypeIn copy];
        
    }
    return self;
}

- (id)initWithID:(int)idIn lat:(double)latIn
             lng:(double)lngIn locationName:(NSString*)locationNameIn
        spotName:(NSString*)spotNameIn
            free:(Boolean)freeIn
        spotType:(NSString*)spotTypeIn
        imageIDs:(NSArray*)imageIDsIn
landscapeInfoImageIDs:(NSArray*)landscapeInfoImageIDs
landscapeConfImageIDs:(NSArray*)landscapeConfImageIDs
standardImageIDs:(NSDictionary*)standardImageIDs
      spotLayout:(NSString*)spotLayoutIn
  spotDifficulty:(NSString*)spotDifficultyIn
    spotCoverage:(NSString*)spotCoverageIn
     spotSignage:(NSString*)spotSignageIn
            desc:(NSString*)descIn
          offers:(NSMutableArray*)offersIn
         address:(NSString*)addrIn
      directions:(NSString*)dirIn {


    if ((self = [super init])) {
        self.mID = idIn;
        self.mLat = latIn;
        self.mLong = lngIn;
        self.mLocationName = [locationNameIn copy];
        self.mSpotName = [spotNameIn copy];
        self.mFree = freeIn;
        self.mRemove = false;
        self.imageIDs = [imageIDsIn copy];
        self.landscapeInfoImageIDs = [landscapeInfoImageIDs copy];
        self.landscapeConfImageIDs = [landscapeConfImageIDs copy];
        self.standardImageIDs = [standardImageIDs copy];
        self.mSpotLayout = [spotLayoutIn copy];
        self.mSpotDifficulty = [spotDifficultyIn copy];
        self.mSpotCoverage = [spotCoverageIn copy];
        self.mSpotSignage = [spotSignageIn copy];
        self.mSpotType = [spotTypeIn copy];
        
        self.mDesc = [descIn copy];
        self.offers = offersIn;
        
        self.mAddress = [addrIn copy];
        self.mDirections = [dirIn copy];
    }
    return self;
}


- (double) currentPrice {
    if(self.offers && self.offers.count > 0) {
        Offer* currentOffer = [self.offers objectAtIndex:0];
        if( currentOffer && currentOffer.priceList && currentOffer.priceList.count > 0) {
            PriceInterval* priceInterval = [currentOffer.priceList objectAtIndex:0];
            if (priceInterval) {
                return priceInterval.pricePerHour;
            }
        }
    }
    return 0;
}

- (NSArray*) findPricesInRange:(double)startTime endTime:(double)endTime {
    //ok, so find all price intervals.
    NSMutableArray* arrayIn = [[NSMutableArray alloc] init];
    for (Offer* iterOffer in self.offers) {
        if(startTime >= iterOffer.startTime &&
           startTime <= iterOffer.endTime &&
           endTime >= iterOffer.startTime &&
           endTime <= iterOffer.endTime &&
           endTime >= startTime) {
            [arrayIn addObjectsFromArray:[iterOffer findPricesInRange:startTime endTime:endTime]];
        }
    }
    
    NSMutableArray* toRtn = [[NSMutableArray alloc] init];
    for (NSNumber* num in arrayIn) {
        if (![toRtn containsObject:num]) {
            [toRtn addObject:num];
        }
    }
    return toRtn;
}

- (double) endTime {
    double toRtn = 0;
    for (Offer* offer in self.offers) {
        toRtn = MAX(toRtn, offer.endTime);
    }
    return toRtn;
}

- (double) priceFromNowForDurationInSeconds:(double)duration {
    NSDate* currentDate = [NSDate date];
    double currentTime = [currentDate timeIntervalSince1970];
    //now for each offer, find cost.
    double toRtn = 0;
    
    for (Offer* iterOffer in self.offers) {
        double startTime = MAX(currentTime, iterOffer.startTime);
        double endTime = MIN(currentTime+duration, iterOffer.endTime);
        if (endTime - startTime > 0) {
            toRtn += [iterOffer findCostWithStartTime:startTime endTime:endTime];
        }
    }
    return toRtn;
}

- (void) updateAsynchronouslyWithLevelOfDetail:(NSString*)lod {
    [self.parentCollection updateWithRequest:[NSDictionary dictionaryWithObjectsAndKeys:@"one",@"count",[NSNumber numberWithInt:self.mID], @"id", lod, @"level_of_detail", nil]];
}


- (NSDictionary*) asDictionary {
    NSMutableDictionary* dictOut = [[NSMutableDictionary alloc]init];
    [dictOut setObject:[NSNumber numberWithInt:self.mID] forKey:@"id"];
    [dictOut setObject:[NSNumber numberWithBool:self.mFree] forKey:@"free"];
    [dictOut setObject:self.mSpotName forKey:@"title"];
    [dictOut setObject:self.mDesc forKey:@"description"];
    [dictOut setObject:self.imageIDs forKey:@"imageIDs"];
    [dictOut setObject:self.landscapeInfoImageIDs forKey:@"land_info"];
    [dictOut setObject:self.landscapeConfImageIDs forKey:@"land_conf"];
    [dictOut setObject:self.standardImageIDs forKey:@"standard"];
    
    NSMutableDictionary* location = [[NSMutableDictionary alloc]init];
    [location setObject:[NSNumber numberWithDouble:self.mLat] forKey:@"latitude"];
    [location setObject:[NSNumber numberWithDouble:self.mLong] forKey:@"longitude"];
    [location setObject:self.mLocationName forKey:@"location_name"];
    [location setObject:self.mAddress forKey:@"location_address"];
    [location setObject:self.mDirections forKey:@"directions"];
    
    [dictOut setObject:location forKey:@"location"];
    
    NSMutableDictionary* qp = [[NSMutableDictionary alloc]init];
    [qp setObject:self.mSpotLayout forKey:@"spot_layout"];
    [qp setObject:self.mSpotDifficulty forKey:@"spot_difficulty"];
    [qp setObject:self.mSpotCoverage forKey:@"spot_coverage"];
    [qp setObject:self.mSpotSignage forKey:@"spot_signage"];
    [qp setObject:self.mSpotType forKey:@"spot_type"];
    
    [dictOut setObject:qp forKey:@"quick_properties"];
    
    [dictOut setObject:[[NSDictionary alloc] init] forKey:@"offers"];
    
    return dictOut;
    
}

- (BOOL) updateFromDictionary:(NSDictionary*)spot withLevelOfDetail:(NSString*)levelOfDetail {
    
        
    //ID
    int idIn = [[spot objectForKey:@"id"] intValue];
    self.mID = idIn;
    
    Boolean freeIn = [[spot objectForKey:@"free"] boolValue];
    self.mFree = freeIn;
    
    
    //Latitutde and Longitude
    self.mLat = [[[spot objectForKey:@"location"] objectForKey:@"latitude" ] doubleValue];
    self.mLong = [[[spot objectForKey:@"location"] objectForKey:@"longitude" ] doubleValue];
    
    //Location and Spot Name
    self.mLocationName = [[spot objectForKey:@"location"] objectForKey:@"location_name" ];
    self.mSpotName = [spot objectForKey:@"title"];
    
    
    NSDictionary* quickPropertiesIn = [spot objectForKey:@"quick_properties"];
    
    self.mSpotLayout = @"";
    self.mSpotDifficulty = @"";
    self.mSpotCoverage = @"";
    self.mSpotSignage = @"";
    self.mSpotType = @"";
    
    if ([quickPropertiesIn objectForKey:@"spot_layout"]) {
        self.mSpotLayout = [quickPropertiesIn objectForKey:@"spot_layout"];
    }
    if ([quickPropertiesIn objectForKey:@"spot_difficulty"]) {
        self.mSpotDifficulty = [quickPropertiesIn objectForKey:@"spot_difficulty"];
    }
    if ([quickPropertiesIn objectForKey:@"spot_coverage"]) {
        self.mSpotCoverage = [quickPropertiesIn objectForKey:@"spot_coverage"];
    }
    if ([quickPropertiesIn objectForKey:@"spot_signage"]) {
        self.mSpotSignage = [quickPropertiesIn objectForKey:@"spot_signage"];
    }
    if ([quickPropertiesIn objectForKey:@"spot_type"]) {
        self.mSpotType = [quickPropertiesIn objectForKey:@"spot_type"];
    }
    
    
    NSMutableArray* imageIds = [[NSMutableArray alloc] init];
    for (id imageId in [spot objectForKey:@"imageIDs"]) {
        [imageIds addObject:imageId];
    }
    self.imageIDs = [imageIds copy];
    
    
    self.landscapeInfoImageIDs = [spot objectForKey:@"land_info"];
   /* if ([imageIds class] != [NSArray class]){
        imageIds = 
    }
    NSMutableArray* landscapeInfoImageIDs = [[NSMutableArray alloc] init];
    
    for (id imageId in [spot objectForKey:@"land_info"]) {
        [landscapeInfoImageIDs addObject:imageId];
    }
    self.landscapeInfoImageIDs = [landscapeInfoImageIDs copy];
    
    */
    NSMutableArray* landscapeConfImageIDs = [[NSMutableArray alloc] init];
    for (id imageId in [spot objectForKey:@"land_conf"]) {
        [landscapeConfImageIDs addObject:imageId];
    }
    self.landscapeConfImageIDs = [imageIds copy];
    
    
    /*
    NSMutableArray* standardImageIDs = [[NSMutableArray alloc] init];
    for (id imageId in [spot objectForKey:@"standard"]) {
        [standardImageIDs addObject:imageId];
    }
     */
    self.standardImageIDs = [[spot objectForKey:@"standard"] copy];
    
    

   // if ([levelOfDetail isEqualToString:@"all"] && freeIn) {
        self.mDesc = [spot objectForKey:@"description"];
        NSMutableArray* offersIn = [[NSMutableArray alloc] init];
    if (freeIn){
        for (NSDictionary* offer in [spot objectForKey:@"offers"]) {
            [offersIn addObject:[[Offer alloc] initFromDictionary:offer]];
        }
    }
        self.offers = offersIn;

        self.mAddress = [[spot objectForKey:@"location"] objectForKey:@"location_address"];

        self.mDirections = [[spot objectForKey:@"location"] objectForKey:@"directions"];
    //}
    if(!freeIn) {
        return false;
    }

    return true;
}




- (int)idForName:(NSString *)name {
    return [[self.standardImageIDs objectForKey:name] intValue];
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
    return [NSString stringWithFormat:@"%@ Spot", self.spot.mSpotType];
}
- (NSString *)subtitle {
    
    if (ADMIN_VER) {
        NSString* adminExtra = [NSString stringWithFormat:@" <#%d>", self.spot.mID];
        return [NSString stringWithFormat:@"%@%@", self.spot.mLocationName, adminExtra];
    }
    return [NSString stringWithFormat:@"%@", [TextFormatter formatSecuredAddressString:self.spot.mLocationName]];
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



@implementation LocationAnnotation

@synthesize coordinate = _coordinate;

@end


