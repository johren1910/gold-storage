//
//  AppDelegate.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "AppDelegate.h"
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HomeView" bundle:nil];
    HomeViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    UINavigationController *navigationController=[[UINavigationController alloc] initWithRootViewController:ivc];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
