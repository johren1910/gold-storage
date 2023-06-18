//
//  HomeCoordinator.m
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//

#import <Foundation/Foundation.h>
#import "HomeCoordinator.h"
#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface HomeCoordinator () <HomeViewModelCoordinatorDelegate>

@property (strong, nonatomic) UINavigationController * navigationController;

@end

@implementation HomeCoordinator

- (instancetype) init: (UINavigationController*) navigationController {
    _navigationController = navigationController;
    return self;
}

- (void) start {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HomeView" bundle:nil];
    HomeViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    HomeViewModel* viewModel = [[HomeViewModel alloc] init];
    viewModel.coordinatorDelegate = self;
    [ivc setViewModel:viewModel];
    [_navigationController setViewControllers:@[ivc] animated:TRUE];
}

#pragma mark - HomeViewModelCoordinatorDelegate
-(void)didTapSetting {
    //Navigate to setting
    NSLog(@"Navigate to setting");
    
}

@end
