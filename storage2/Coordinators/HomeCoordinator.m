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
#import "ChatDetailViewController.h"
#import "ChatDetailViewModel.h"
#import "StorageViewModel.h"
#import "StorageViewController.h"
#import "StorageManager.h"

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
    viewModel.storageManager = _storageManager;
    viewModel.downloadManager = _downloadManager;
    viewModel.coordinatorDelegate = self;
    [ivc setViewModel:viewModel];
    [_navigationController setViewControllers:@[ivc] animated:TRUE];
}

#pragma mark - HomeViewModelCoordinatorDelegate
-(void)didTapSetting {
    //Navigate to setting
    NSLog(@"Navigate to setting");
    
    StorageViewModel* viewModel = [[StorageViewModel alloc] init];
//    viewModel.databaseManager = _databaseManager;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StorageView" bundle:nil];
    StorageViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"StorageViewController"];
    ivc.title = @"Storage";
    
    [self.navigationController pushViewController:ivc animated:true];
}

-(void)didTapChatRoom: (ChatRoomModel*) chatRoom {
    //Navigate to chatRoom detail
    NSLog(@"Navigate to chatRoom");
    
    ChatDetailViewModel* viewModel = [[ChatDetailViewModel alloc] initWithChatRoom:chatRoom];
    viewModel.storageManager = _storageManager;
    viewModel.downloadManager = _downloadManager;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatDetailView" bundle:nil];
    ChatDetailViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"ChatDetailViewController"];
    
    ivc = [ivc initWithViewModel:viewModel];
    ivc.title = chatRoom.name;
    
    [self.navigationController pushViewController:ivc animated:true];
}

@end
