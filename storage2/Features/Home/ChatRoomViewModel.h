//
//  HomeViewModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomModel.h"
#import "ChatRoomSectionController.h"
#import "StorageManagerType.h"
#import "ZODownloadManagerType.h"

@protocol ChatRoomViewModelDelegate

- (void) didUpdateData;
- (void) didUpdateObject:(ChatRoomModel*)model;
- (void) didReloadData;

@end

@protocol ChatRoomViewModelCoordinatorDelegate <NSObject>

-(void)didTapSetting;
-(void)didTapChatRoom: (ChatRoomModel*) chatRoom;

@end

@interface ChatRoomViewModel : NSObject
- (void) selectChatRoom:(ChatRoomModel *) chatRoom;
- (void) deselectChatRoom:(ChatRoomModel *) chatRoom;
- (void) deleteSelected;
- (void)getData:(void (^)(NSMutableArray<ChatRoomModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;

- (ChatRoomModel *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
- (void)createNewChat: (NSString *) name;

@property (strong,nonatomic) NSMutableArray<ChatRoomModel *> *chats;

@property (nonatomic, weak) id <ChatRoomViewModelDelegate>  delegate;
@property (nonatomic, strong) id <ChatRoomViewModelCoordinatorDelegate>  coordinatorDelegate;
@property (nonatomic, strong) id<StorageManagerType> storageManager;
@property (nonatomic, strong) id<ZODownloadManagerType> downloadManager;

@end
