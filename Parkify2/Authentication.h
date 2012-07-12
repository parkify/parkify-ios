//
//  Authentication.h
//  Parkify2
//
//  Created by Me on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserRegistrationRequest : NSObject

@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * password;
@property (strong, nonatomic) NSString * password_confirmation;

- (id)initWithEmail:(NSString *)email withPassword:(NSString *)password withPasswordConfirmation:(NSString *)passwordConfirmation;

@end


@interface Authentication : NSObject

@end
