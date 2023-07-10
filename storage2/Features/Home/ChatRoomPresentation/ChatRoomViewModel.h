//
//  HomeViewModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomData.h"
#import "ChatRoomSectionController.h"
#import "ChatRoomUseCase.h"
#import "DIInterface.h"

@protocol ChatRoomViewModelDelegate

- (void) didUpdateData;
- (void) didUpdateObject:(ChatRoomEntity*)model;
- (void) didReloadData;
- (void) startLoading;
- (void) endLoading;

@end

@protocol ChatRoomViewModelCoordinatorDelegate <NSObject>

-(void)didTapSetting;
-(void)didTapChatRoom: (ChatRoomEntity*) chatRoom;

@end

@protocol ChatRoomViewModelType <ViewModelType>

-(instancetype) initWithUseCase:(id<ChatRoomUseCaseInterface>)chatDetailUsecase;

@end

@interface ChatRoomViewModel : NSObject <ChatRoomViewModelType>

#pragma mark - Actions
- (void)selectChatRoom:(ChatRoomEntity *) chatRoom;
- (void)deselectChatRoom:(ChatRoomEntity *) chatRoom;
- (void)deleteSelected;
- (void)requestCreateNewChat: (NSString *) name;
- (void) onViewDidLoad;

- (ChatRoomEntity *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;

@property (strong,nonatomic) NSMutableArray<ChatRoomEntity *> *chats;

@property (nonatomic, weak) id <ChatRoomViewModelDelegate>  delegate;
@property (nonatomic, strong) id <ChatRoomViewModelCoordinatorDelegate>  coordinatorDelegate;
@property (nonatomic) id<ChatRoomUseCaseInterface> chatRoomUsecase;
@end
