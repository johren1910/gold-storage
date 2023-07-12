//
//  HomeViewModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomData.h"
#import "ChatRoomSectionController.h"
#import "ChatRoomBusinessModel.h"
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

-(instancetype) initWithBusinessModel:(id<ChatRoomBusinessModelInterface>)chatDetailBusinessModel;
- (void)selectChatRoom:(ChatRoomEntity *) chatRoom;
- (void)deselectChatRoom:(ChatRoomEntity *) chatRoom;
- (void)deleteSelected;
- (void)requestCreateNewChat: (NSString *) name;
- (void) onViewDidLoad;

- (ChatRoomEntity *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
@property (nonatomic, weak) id <ChatRoomViewModelDelegate>  delegate;
@property (nonatomic, strong) id <ChatRoomViewModelCoordinatorDelegate>  coordinatorDelegate;

@property (strong,nonatomic) NSMutableArray<ChatRoomEntity *> *chats;
@end

@interface ChatRoomViewModel : NSObject <ChatRoomViewModelType>

@property (nonatomic) id<ChatRoomBusinessModelInterface> chatRoomBusinessModel;
@end
