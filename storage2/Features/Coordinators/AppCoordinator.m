//
//  AppCoordinator.m
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//

#import <Foundation/Foundation.h>
#import "AppCoordinator.h"
#import "ChatRoomCoordinator.h"
#import "ChatRoomViewController.h"

@interface AppCoordinator () <ChatRoomCoordinatorDelegate>
@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) AppEnvironment* appEnvironment;
@property (strong, nonatomic) AppDI* appDI;

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
    _appEnvironment = [[AppEnvironment alloc] init];
    _appDI = [AppDI shared];
    
    _rootViewController = [[UINavigationController alloc] init];

    _window.rootViewController = _rootViewController;
    [_window makeKeyAndVisible];
    [self homeFLow];
}

- (void) homeFLow {
    ChatRoomCoordinator* chatRoomCoordinator = [[ChatRoomCoordinator alloc] init:_rootViewController andAppDI:_appDI];
    
    chatRoomCoordinator.delegate = self;
    [self store:chatRoomCoordinator];
    [chatRoomCoordinator start];
}

@end
