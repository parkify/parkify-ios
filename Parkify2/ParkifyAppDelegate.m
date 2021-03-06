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

@implementation ParkifyAppDelegate

@synthesize window = _window;
@synthesize user = _user;
@synthesize parkingSpots = _parkingSpots;

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
    //[Flurry startSession:@"TS2D3KM78SMZ8MJWNYNV"];
    
    //[PlacedAgent initWithAppKey:@"6f15dab4fc2d"];
    //[PlacedAgent logStartSession];
  
    
  
    return YES;
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
