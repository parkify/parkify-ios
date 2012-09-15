//
//  Formatter.h
//  Parkify2
//
//  Created by Me on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TEXTFIELD_BORDER_COLOR [UIColor colorWithRed:48.0/255 green:95.0/255 blue:230.0/255 alpha:1]
#define TEXTFIELD_HEIGHT 35

@interface TextFormatter : NSObject
+ (CGAffineTransform) transformForSpotViewText;
+ (CGAffineTransform) transformForSignupViewText;
+ (NSString*) formatDistanceClose:(double)distanceInMiles;
+ (NSString*) formatIdString:(int)idIn;
@end
