//
//  AppCoordinator.h
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//
#import "BaseCoordinator.h"
#import <UIKit/UIKit.h>
#import "DatabaseManager.h"
#import "CacheManager.h"

@interface AppCoordinator : BaseCoordinator

@property (strong, nonatomic) UIWindow * window;

@property (strong, nonatomic) UINavigationController* rootViewController;

- (instancetype) init: (UIWindow *)window;

@end
