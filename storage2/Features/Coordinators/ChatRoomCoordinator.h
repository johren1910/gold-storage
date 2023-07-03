//
//  HomeCoordinator.h
//  storage2
//
//  Created by LAP14885 on 18/06/2023.
//
#import "BaseCoordinator.h"
#import <UIKit/UIKit.h>
#import "AppDI.h"

@protocol ChatRoomCoordinatorDelegate
@end

@interface ChatRoomCoordinator : BaseCoordinator
- (instancetype) init: (UINavigationController*) navigationController andAppDI:(AppDI*)appDI;
@property (nonatomic, weak) id <ChatRoomCoordinatorDelegate> delegate;
@end
