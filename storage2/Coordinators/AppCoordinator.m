//
//  AppCoordinator.m
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//

#import <Foundation/Foundation.h>
#import "AppCoordinator.h"
#import "HomeCoordinator.h"
#import "HomeViewController.h"

@interface AppCoordinator () <HomeCoordinatorDelegate>
@end

@implementation AppCoordinator

- (instancetype) init: (UIWindow *)window {
    _window = window;
    return self;
}

- (void) start {
    if (_window == nil) {
        return;
    }
    _rootViewController = [[UINavigationController alloc] init];
    
    _databaseManager = [DatabaseManager getSharedInstance];
    
    _window.rootViewController = _rootViewController;
    [_window makeKeyAndVisible];
    [self homeFLow];
}

- (void) homeFLow {
    HomeCoordinator* homeCoordinator = [[HomeCoordinator alloc] init:_rootViewController];
    
    homeCoordinator.databaseManager = _databaseManager;
    homeCoordinator.delegate = self;
    [self store:homeCoordinator];
    [homeCoordinator start];
}

@end
