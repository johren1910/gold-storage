//
//  HomeCoordinator.h
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//
#import "BaseCoordinator.h"
#import <UIKit/UIKit.h>
#import "DatabaseManager.h"
#import "CacheManager.h"

@protocol HomeCoordinatorDelegate
@end

@interface HomeCoordinator : BaseCoordinator
- (instancetype) init: (UINavigationController*) navigationController;
@property (nonatomic, weak) id <HomeCoordinatorDelegate> delegate;
@property (strong, nonatomic) DatabaseManager * databaseManager;
@property (strong, nonatomic) CacheManager * cacheManager;
@end
