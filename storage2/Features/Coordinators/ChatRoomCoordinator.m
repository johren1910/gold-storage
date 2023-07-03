//
//  HomeCoordinator.m
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomCoordinator.h"
#import <UIKit/UIKit.h>
#import "ChatRoomViewController.h"
#import "ChatDetailViewController.h"
#import "ChatDetailViewModel.h"
#import "StorageViewModel.h"
#import "StorageViewController.h"
#import "AppDI.h"

@interface ChatRoomCoordinator () <ChatRoomViewModelCoordinatorDelegate>

@property (strong, nonatomic) UINavigationController * navigationController;

@property (strong, nonatomic) AppDI * appDI;

@end

@implementation ChatRoomCoordinator

- (instancetype) init: (UINavigationController*) navigationController andAppDI:(AppDI *)appDI {
    if (self == [super init]) {
        self.navigationController = navigationController;
        self.appDI = appDI;
    }
    
    return self;
}

- (void) start {
    
    ChatRoomViewModel* viewModel = [_appDI chatRoomDependencies];
    viewModel.coordinatorDelegate = self;
    
    ChatRoomViewController *viewController = [[ChatRoomViewController alloc] initWithViewModel:viewModel];
    
    [_navigationController setViewControllers:@[viewController] animated:TRUE];
}

#pragma mark - HomeViewModelCoordinatorDelegate

-(void)didTapChatRoom: (ChatRoomModel*) chatRoom {
    
    ChatDetailViewModel* viewModel = [_appDI chatDetailDependencies:chatRoom];
    ChatDetailViewController *viewController = [[ChatDetailViewController alloc] initWithViewModel:viewModel];
    viewController.title = chatRoom.name;
    
    [self.navigationController pushViewController:viewController animated:true];
}

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

@end
