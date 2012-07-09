//
//  ParkingSpot.h
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class ParkingSpot;

@protocol ParkingSpotObserver <NSObject>

-(void)spotsWereUpdated;

@end

@interface ParkingSpotCollection : NSObject
- (ParkingSpot*)parkingSpotForID:(int)key;
- (id)initFromJSONString:(NSString*)strJson;
- (void)updateFromJSONString:(NSString*)strJson;
- (void)updateWithRequest:(id)Request;
@property (nonatomic, strong) NSDictionary* parkingSpots;
@property (nonatomic, weak) id <ParkingSpotObserver> observerDelegate;
@end

@interface ParkingSpot : NSObject {
    int _mID;
    double _mLat;
    double _mLong;
    NSString *_mCompanyName;
    int _mLocalID;
    double _mPrice;
    NSString *_mPhoneNumber;
    NSString *_mDesc;
    Boolean _mFree;
    
    Boolean _mRemove;
}



@property int mID;
@property double mLat;
@property double mLong;
@property (copy) NSString *mCompanyName;
@property int mLocalID;
@property double mPrice;
@property (copy) NSString *mPhoneNumber;
@property (copy) NSString *mDesc;
@property Boolean mFree;
@property Boolean mRemove;


- (id)initWithID:(int)idIn lat:(double)latIn
             lng:(double)lngIn companyName:(NSString*)companyNameIn
         localID:(int)localIDIn price:(double)priceIn
     phoneNumber:(NSString*)phoneNumberIn desc:(NSString*)descIn
            free:(Boolean)freeIn;
@end

@interface ParkingSpotAnnotation : NSObject <MKAnnotation> 

@property (nonatomic, strong) ParkingSpot* spot;

+ (ParkingSpotAnnotation *)annotationForSpot:(ParkingSpot*)spot;

//Returns true if the annotation was updated.
- (BOOL)updateAnnotationWith:(id)annotation onlyifIDsAreSame:(BOOL)boolIDsSame;

@end