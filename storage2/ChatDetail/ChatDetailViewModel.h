//
//  ChatDetailViewModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//
#import <Foundation/Foundation.h>
#import "ChatDetailSectionController.h"
#import "ChatRoomModel.h"
#import "StorageManagerType.h"
#import "ZODownloadManager.h"

@protocol ChatDetailViewModelDelegate <NSObject>

- (void) didUpdateData;
- (void) didUpdateObject:(ChatMessageModel*)model;
- (void) didReloadData;

@end

@interface ChatDetailViewModel : NSObject

- (void) selectChatMessage:(ChatMessageModel *) chat;
- (void) deselectChatMessage:(ChatMessageModel *) chat;
- (void)getData:(void (^)(NSArray<ChatMessageModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;
- (void)changeSegment: (NSInteger) index;
- (ChatMessageModel *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
- (void)addImage:(NSData *)data;
- (void)addFile:(NSData *)data;
- (void)downloadFileWithUrl:(NSString *)url;
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
- (void)deleteSelected;

@property (nonatomic, weak) id <ChatDetailViewModelDelegate>  delegate;
@property (copy,nonatomic) NSArray<ChatMessageModel *> *filteredChats;
@property (nonatomic, strong) id<StorageManagerType> storageManager;
@property (nonatomic, strong) id<ZODownloadManagerType> downloadManager;

-(instancetype) initWithChatRoom: (ChatRoomModel*) chatRoom;
@end
