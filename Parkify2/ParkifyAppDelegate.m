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
@implementation ParkifyAppDelegate

@synthesize window = _window;
@synthesize user = _user;
@synthesize parkingSpots = _parkingSpots;
@synthesize transactions = _transactions;
@synthesize openURL= _openURL;
@synthesize  isNew = _isNew;
@synthesize currentLat = _currentLat;
@synthesize currentLong = _currentLong;
-(NSMutableDictionary*)transactions{
    if (![Persistance retrieveUserID])
        return nil;
    if(!transactions){
        NSDictionary *trans = [Persistance retrieveTransactions];

        transactions= [[NSMutableDictionary alloc] init];
        NSMutableDictionary *actvies = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *alltrans = [[NSMutableDictionary alloc] init];
        [transactions setValue:actvies forKey:@"active"];
        [transactions setValue:alltrans forKey:@"all"];
        
        if(trans){
            double currentTime = [[NSDate date] timeIntervalSince1970];
            NSDictionary *aller = [trans objectForKey:@"all"];
            for (NSString *transactionkey in aller){
                NSDictionary *transaction = [aller objectForKey:transactionkey];
                NSMutableDictionary *thistransaction = [NSMutableDictionary dictionaryWithDictionary:transaction];
                NSLog(@"transaction is %@", transaction);
                double startTime = [[transaction objectForKey:@"starttime"] doubleValue];
                double endTime =[[transaction objectForKey:@"endtime"] doubleValue];
                
                if ((currentTime >= startTime) && (currentTime <= endTime)){
                    [thistransaction setValue:@"1" forKey:@"active"];
                    [actvies setValue:thistransaction forKey:[NSString stringWithFormat:@"%i", [[thistransaction objectForKey:@"spotid"] intValue] ]];
                }
                else{
                    [thistransaction setValue:@"0" forKey:@"active"];

                }
                [alltrans setValue:thistransaction forKey:[NSString stringWithFormat:@"%i", [[thistransaction objectForKey:@"spotid"] intValue] ]];


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
    if(request.tag == kLoadUDIDandPush){
        NSString *responseString = [request responseString];
        NSDictionary * root = [responseString JSONValue];
        NSLog(@"Finished %@", responseString);

        BOOL success = [[root objectForKey:@"success"] boolValue];
        isNew = [[root objectForKey:@"isNew"] boolValue];
        if(success) {
            NSLog(@"Saved device %@", root);
        } else {
            NSLog(@"Failed ot save device %@", root);
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
