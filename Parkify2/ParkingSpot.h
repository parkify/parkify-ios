//
//  ParkingSpot.h
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ParkingSpot : NSObject <MKAnnotation> {
    int _mID;
    double _mLat;
    double _mLong;
    NSString *_mCompanyName;
    int _mLocalID;
    double _mPrice;
    NSString *_mPhoneNumber;
    NSString *_mDesc;
    Boolean _mFree;
    CLLocationCoordinate2D coordinate;
    
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
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property Boolean mRemove;

- (id)initWithID:(int)idIn lat:(double)latIn
             lng:(double)lngIn companyName:(NSString*)companyNameIn
         localID:(int)localIDIn price:(double)priceIn
     phoneNumber:(NSString*)phoneNumberIn desc:(NSString*)descIn
            free:(Boolean)freeIn;

@end

//{"mID"="1","mLat"="37.872708","mLong"="-122.266824","mCompanyName"="Mike's Bikes","mLocalID"="1","mPrice"="5.0","mPhoneNumber"="408-421-1194","mDesc"="A Fantastic Spot!","mFree"="true"}