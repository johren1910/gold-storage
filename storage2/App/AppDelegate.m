//
//  AppDelegate.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "AppCoordinator.h"

@interface AppDelegate ()
@property (strong,nonatomic) AppCoordinator * appCoordinator;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    _appCoordinator = [[AppCoordinator alloc] init:_window];
    [_appCoordinator start];
    
    return YES;
}

@end
