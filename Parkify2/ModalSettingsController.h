//
//  ModalSettingsController.h
//  Parkify2
//
//  Created by Me on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ExtraTypes.h"

@interface ModalSettingsController : UITabBarController

@property (weak, nonatomic) SuccessBlock successBlock;

- (void) exitWithResults:(NSDictionary *)results;
@end
