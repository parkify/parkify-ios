//
//  DirectionsControl.h
//  Parkify
//
//  Created by Me on 10/23/12.
//
//

#import <UIKit/UIKit.h>
#import "ExtraTypes.h"

@interface DirectionsControl : UIControl

- (id)initWithFrame:(CGRect)frame withDirections:(NSString*)directionsString withResolutionDelegate:(id<NameIdMappingDelegate>)delegate;
- (NSString*)htmlForDirections;
@end
