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
@property (strong, nonatomic) AppService* appService;
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
    _appService = [[AppService alloc] init];
//    [_appService registerServices];
    
    _rootViewController = [[UINavigationController alloc] init];

    _window.rootViewController = _rootViewController;
    [_window makeKeyAndVisible];
    [self homeFLow];
}

- (void) homeFLow {
    HomeCoordinator* homeCoordinator = [[HomeCoordinator alloc] init:_rootViewController];
    
    homeCoordinator.storageManager = [_appService getService:StorageManager.class];
    homeCoordinator.downloadManager = [_appService getService:ZODownloadManager.class];
    homeCoordinator.delegate = self;
    [self store:homeCoordinator];
    [homeCoordinator start];
}

@end
