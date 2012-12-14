//
//  ParkingSpot.h
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Offer.h"

#import "ExtraTypes.h"




@class ParkingSpotCollection;

@protocol ParkingSpotObserver <NSObject>

-(void)spotsWereUpdatedWithCount:(NSString*)count withLevelOfDetail:(NSString*)lod withSpot:(int)spotID;

@end



@interface ParkingSpot : NSObject<PriceStore, NameIdMappingDelegate, MKAnnotation>

@property (strong, nonatomic) ParkingSpotCollection* parentCollection;


@property int mID;
@property double mLat;
@property double mLong;

@property (strong, nonatomic) NSString* mLocationName;
@property (strong, nonatomic) NSString* mSpotName;



@property (strong, nonatomic) NSString *mDesc;
@property Boolean mFree;
@property Boolean mRemove;
@property (strong, nonatomic) NSMutableArray* offers;

@property (strong, nonatomic) NSString* mSpotLayout;
@property (strong, nonatomic) NSString* mSpotDifficulty;
@property (strong, nonatomic) NSString* mSpotCoverage;
@property (strong, nonatomic) NSString* mSpotSignage;
@property (strong, nonatomic) NSString* mSpotType;

@property (strong, nonatomic) NSString* mAddress;
@property (strong, nonatomic) NSString* mDirections;

@property (strong, nonatomic) NSArray* imageIDs;
@property (strong, nonatomic) NSArray* landscapeInfoImageIDs;
@property (strong, nonatomic) NSArray* landscapeConfImageIDs;
@property (strong, nonatomic) NSDictionary* standardImageIDs;
@property (strong, nonatomic) NSObject *parkingSpotAnnotation;



@property int offerID;


- (id)initWithID:(int)idIn lat:(double)latIn
             lng:(double)lngIn locationName:(NSString*)locationNameIn
        spotName:(NSString*)spotNameIn
            free:(Boolean)freeIn
        spotType:(NSString*)spotTypeIn
       imageIDs:(NSArray*)imageIDsIn

      spotLayout:(NSString*)spotLayoutIn
  spotDifficulty:(NSString*)spotDifficultyIn
    spotCoverage:(NSString*)spotCoverageIn
     spotSignage:(NSString*)spotSignageIn;

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
          offers:(NSArray*)offersIn
         address:(NSString*)addrIn
      directions:(NSString*)dirIn;

- (double) currentPrice;

- (double) endTime;

- (double) priceFromNowForDurationInSeconds:(double)duration;

- (void) updateAsynchronouslyWithLevelOfDetail:(NSString*)lod;

- (BOOL) updateFromDictionary:(NSDictionary*)spot withLevelOfDetail:(NSString*)levelOfDetail;

- (NSDictionary*) asDictionary;

- (NSArray*) findPricesInRange:(double)startTime endTime:(double)endTime;

- (int)idForName:(NSString *)name;

@end



@interface ParkingSpotAnnotation : NSObject <MKAnnotation> 

@property (nonatomic, strong) ParkingSpot* spot;

+ (ParkingSpotAnnotation *)annotationForSpot:(ParkingSpot*)spot;

//Returns true if the annotation was updated.
- (BOOL)updateAnnotationWith:(id)annotation onlyifIDsAreSame:(BOOL)boolIDsSame;

@end


@interface LocationAnnotation : NSObject <MKAnnotation> 

@property (nonatomic) CLLocationCoordinate2D coordinate;
@end