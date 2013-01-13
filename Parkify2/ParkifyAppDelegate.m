//
//  Parkify2AppDelegate.m
//  Parkify2
//
//  Created by Me on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParkifyAppDelegate.h"
//#import "Flurry.h"
//#import "PlacedAgent.h"
#import "Persistance.h"
#import "Api.h"
#import "ExtraTypes.h"
#import "SBJson.h"
#import "ErrorTransformer.h"
#import "Acceptance.h"
@implementation ParkifyAppDelegate

@synthesize window = _window;
@synthesize user = _user;
@synthesize parkingSpots = _parkingSpots;
@synthesize transactions = _transactions;
@synthesize openURL= _openURL;
@synthesize  isNew = _isNew;
@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;
@synthesize reservationUsed = _reservationUsed;
-(NSMutableDictionary*)transactions{
    if (![Persistance retrieveAuthToken])
        return nil;
    if(!transactions || [Persistance retrieveRefreshTransactions]){
        [Persistance saveRefreshTransactions:false];
        [Api getListOfCurrentAcceptances:self];
        NSDictionary *trans = [Persistance retrieveTransactions];

        transactions= [[NSMutableDictionary alloc] init];
        NSMutableDictionary *actvies = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *alltrans = [[NSMutableDictionary alloc] init];
        [transactions setValue:actvies forKey:@"active"];
        [transactions setValue:alltrans forKey:@"all"];
        
        if(trans){
           // double currentTime = [[NSDate date] timeIntervalSince1970];
            NSDictionary *aller = [trans objectForKey:@"all"];
            for (NSString *transactionkey in aller){
                NSDictionary *transaction = [aller objectForKey:transactionkey];
                NSObject *thistransaction;
                if ([transaction class] == [Acceptance class]){
                    [alltrans setValue:transaction forKey: ((Acceptance*)transaction).acceptid ];

                }
                else{
                    NSLog(@"Old data..letting it get deleted");
                /*thistransaction = [NSMutableDictionary dictionaryWithDictionary:transaction];
                NSLog(@"transaction is %@", transaction);
                    [alltrans setValue:thistransaction forKey:[NSString stringWithFormat:@"%i", [[transaction objectForKey:@"acceptanceid"] intValue] ]];
*/
                }
            //    double startTime = [[transaction objectForKey:@"starttime"] doubleValue];
             //   double endTime =[[transaction objectForKey:@"endtime"] doubleValue];
             //
                //if ((currentTime >= startTime) && (currentTime <= endTime)){
                  //  [thistransaction setValue:@"1" forKey:@"active"];
                //    [actvies setValue:thistransaction forKey:[NSString stringWithFormat:@"%i", [[thistransaction objectForKey:@"spotid"] intValue] ]];
               // }
               // else{
                 //   [thistransaction setValue:@"0" forKey:@"active"];

//                }


            }
        }
        

    }
    return transactions;
}
-(User*) user {
  if(!_user) {
    _user = [[User alloc] init];
  }
  return _user;
}

-(ParkingSpotCollection*) parkingSpots{
    if(!_parkingSpots) {
        _parkingSpots =[[ParkingSpotCollection alloc]init];
    }
    return _parkingSpots;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"****CRASH****:\n%@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [Persistance updatePersistedDataWithAppVersion];
    isNew = TRUE;
    reservationUsed=FALSE;
    [Crittercism enableWithAppID:@"50b3bc587e69a33784000002"];
    [Crittercism leaveBreadcrumb:@"App loaded"];
    [Mixpanel sharedInstanceWithToken:@"0ef037a021b6fa3b5a72057c403d1fbd"];
    [[Mixpanel sharedInstance] track:@"App loaded"];
        // Register with apple that this app will use push notification
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                               
                                                                               UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
        
    //[Flurry startSession:@"TS2D3KM78SMZ8MJWNYNV"];
    
    //[PlacedAgent initWithAppKey:@"6f15dab4fc2d"];
    //[PlacedAgent logStartSession];
  
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"masthead_logo.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setContentMode:UIViewContentModeScaleToFill];
    [[UIBarButtonItem appearance] setTintColor:[UIColor darkGrayColor]];
  
    return YES;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    self.openURL=url;
    NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"launching options %@", text);
   // if ([text isEqualToString:@"extend"]){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"launchURL" object:nil];
   // }
    return YES;
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];

    if(request.tag == kLoadUDIDandPush){
        NSDictionary * root = [responseString JSONValue];
        NSLog(@"Finished %@", responseString);

        BOOL success = [[root objectForKey:@"success"] boolValue];
        isNew = [[root objectForKey:@"isNew"] boolValue];
        reservationUsed = [[root objectForKey:@"reservationUsed"] boolValue];
        if(success) {
            NSLog(@"Saved device %@", root);
        } else {
            NSLog(@"Failed ot save device %@", root);
        }

    }
    
    else if(request.tag == kGetAcceptances){
        if (responseString){
        
            
            NSArray *acceptances = [responseString JSONValue];
            NSDictionary *alltransactionsonphone = [self.transactions objectForKey:@"all"];
            NSDictionary *actives = [self.transactions objectForKey:@"active"];
            NSLog(@"There are %i active reservations", [acceptances count]);
            for (NSDictionary *acceptance in acceptances){
            NSLog(@"Active %@", acceptance);
                if ([[acceptance objectForKey:@"status"] isEqualToString:@"extended"])
                    continue;
                NSNumber *keyer = [NSNumber numberWithInt:[[acceptance objectForKey:@"id"] intValue] ];
                if ([alltransactionsonphone objectForKey:keyer])
                
                {
                    [actives setValue:[alltransactionsonphone objectForKey:keyer] forKey:[NSString stringWithFormat:@"%@", keyer]];
//                    [actives setValue:[alltransactionsonphone objectForKey:[NSString stringWithFormat:@"%i",  [[acceptance objectForKey:@"id"] intValue] ]] forKey:[NSString stringWithFormat:@"%i", [[acceptance objectForKey:@"id"] intValue] ]];
                    
                }
                else{
                    ParkingSpot *thisSpot = [self.parkingSpots parkingSpotForIDFromAll: [[acceptance objectForKey:@"resource_offer_id"] intValue] ];
                    if (thisSpot){
                    Acceptance *thetransaction = [Persistance addNewTransaction: thisSpot withStartTime:[[acceptance objectForKey:@"start_time"] doubleValue] andEndTime:[[acceptance objectForKey:@"end_time"] doubleValue] andLastPaymentDetails:[acceptance objectForKey:@"details"] withTransactionID:[acceptance objectForKey:@"id"]];
                    NSLog(@"Transaction not in records, added in %@", thetransaction);
                    }
                    else{
                        NSLog(@"parking spot not there %@", [acceptance objectForKey:@"resource_offer_id"]);
                    } 
                    
                    //[Persistance addNewTransaction:self.spot withStartTime:self.rangeBar. selectedMinimumValue andEndTime:self.rangeBar.selectedMaximumValue andLastPaymentDetails:[paymentDetails objectForKey:@"details"] withTransactionID:[paymentDetails objectForKey:@"id"]];
                }
            }
            //Check for standalone acceptances or an extensions

        }

    }
}
-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"Failed to register push token and udid!");
}
-(void)sendTokenInfo:(NSString*)tokenAsString{
    [Api registerUDIDandToken:tokenAsString withASIdelegate:self];
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Show the device token obtained from apple to the log
    
    NSLog(@"deviceToken: %@", deviceToken);
    NSString *tokenAsString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    [self sendTokenInfo:tokenAsString];

    
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
    [self sendTokenInfo:@""];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
