//
//  HomeCoordinator.h
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//
#import "BaseCoordinator.h"
#import <UIKit/UIKit.h>

@protocol HomeCoordinatorDelegate

@end

@interface HomeCoordinator : BaseCoordinator
- (instancetype) init: (UINavigationController*) navigationController;
@property (nonatomic, weak) id <HomeCoordinatorDelegate> delegate;
@end
