//
//  Authentication.m
//  Parkify2
//
//  Created by Me on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Authentication.h"

@implementation UserRegistrationRequest

@synthesize email = _email;
@synthesize password = _password;
@synthesize password_confirmation = _password_confirmation;

- (id)initWithEmail:(NSString *)email withPassword:(NSString *)password withPasswordConfirmation:(NSString *)passwordConfirmation {
    self = [super init];
    if(self) {
        self.email = email;
        self.password = password;
        self.password_confirmation = passwordConfirmation;
    }
    return self;
}

@end

@implementation Authentication

@end
