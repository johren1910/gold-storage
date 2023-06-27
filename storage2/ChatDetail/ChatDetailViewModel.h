//
//  ChatDetailViewModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//
#import <Foundation/Foundation.h>
#import "ChatDetailSectionController.h"
#import "ChatRoomModel.h"
#import "DatabaseManager.h"
#import "CacheService.h"
#import "ZODownloadManager.h"

@protocol ChatDetailViewModelDelegate <NSObject>

- (void) didUpdateData;
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
- (void)requestDownloadWithUrl:(NSString *)url forMessageId:(NSString*) messageId;
- (void)deleteSelected;

@property (nonatomic, weak) id <ChatDetailViewModelDelegate>  delegate;
@property (copy,nonatomic) NSArray<ChatMessageModel *> *filteredChats;
@property (nonatomic, strong) id<DatabaseManagerType> databaseManager;
@property (nonatomic, strong) id<CacheServiceType> cacheService;
@property (nonatomic, strong) id<ZODownloadManagerType> downloadManager;

-(instancetype) initWithChatRoom: (ChatRoomModel*) chatRoom;
@end
