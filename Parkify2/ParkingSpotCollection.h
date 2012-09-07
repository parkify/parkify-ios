//
//  ParkingSpotCollection.h
//  Parkify
//
//  Created by Me on 8/16/12.
//
//

#import <Foundation/Foundation.h>
#import "ParkingSpot.h"


@interface ParkingSpotCollection : NSObject
- (ParkingSpot*)parkingSpotForID:(int)key;
- (id)initFromDictionary:(NSDictionary*)root;

- (void)updatefromDictionary:(NSDictionary*)root;
- (void)updateWithRequest:(NSDictionary*)req;
@property (nonatomic, strong) NSDictionary* parkingSpots;
@property (nonatomic, weak) id <ParkingSpotObserver> observerDelegate;
- (ParkingSpot*)closestAvailableSpotToCoord:(CLLocationCoordinate2D)coord;

- (double)distanceToClosestAvailableSpotToCoord:(CLLocationCoordinate2D)coord;
@property (nonatomic, strong) ParkingSpot* currentSpot;


@end