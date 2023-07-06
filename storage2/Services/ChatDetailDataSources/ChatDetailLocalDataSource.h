//
//  ChatDetailLocalDatasourceInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatMessageData.h"
#import "StorageManager.h"

@protocol ChatDetailLocalDataSourceType
- (void)getChatDataOfRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray<ChatMessageData *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void) getFileOfMessageId:(NSString*)messageId completionBlock:(void(^)(FileData* fileData))completionBlock;

- (void)deleteChatMessages:(NSArray<ChatDetailEntity*>*)messages completionBlock:(void(^)(BOOL isComplete))completionBlock;

- (void)updateFileData:(FileData*) fileData completionBlock:(void(^)(BOOL isFinish))completionBlock;

- (void)updateMessageData:(ChatMessageData*) message completionBlock:(void(^)(BOOL isFinish))completionBlock;

- (void) saveImageWithData:(NSData*)data ofRoomId:(NSString*)roomId completionBlock:(void(^)(ChatMessageData* entity)) completionBlock;

- (void)getChatDataForMessageId:(NSString*)messageId completionBlock:(void (^)(ChatMessageData* chat))completionBlock;

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
@end

@interface ChatDetailLocalDataSource : NSObject <ChatDetailLocalDataSourceType>

@property (nonatomic) id<StorageManagerType> storageManager;

@end
