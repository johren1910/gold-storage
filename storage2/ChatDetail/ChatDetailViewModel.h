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

- (void)getData:(void (^)(NSArray<ChatMessageModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;
- (void)changeSegment: (NSInteger) index;
- (ChatMessageModel *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
- (void)addImage:(NSData *)data;
- (void)addFile:(NSData *)data;
- (void)downloadFileWithUrl:(NSString *)url;
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
- (void)requestDownloadWithUrl:(NSString *)url forMessageId:(NSString*) messageId;

@property (nonatomic, weak) id <ChatDetailViewModelDelegate>  delegate;
@property (copy,nonatomic) NSArray<ChatMessageModel *> *filteredChats;
@property (nonatomic, strong) DatabaseManager* databaseManager;
@property (nonatomic, strong) CacheService* cacheService;
@property (nonatomic, strong) ZODownloadManager* downloadManager;

-(instancetype) initWithChatRoom: (ChatRoomModel*) chatRoom;
@end
