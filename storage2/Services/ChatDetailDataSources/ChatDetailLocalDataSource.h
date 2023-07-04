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

- (void) saveMedia:(NSString*)filePath forMessage:(ChatMessageData*)message;

- (void)updateFileData:(FileData*) fileData completionBlock:(void(^)(BOOL isFinish))completionBlock;

- (void) saveImageWithData:(NSData*)data;
@end

@interface ChatDetailLocalDataSource : NSObject <ChatDetailLocalDataSourceType>

@property (nonatomic) id<StorageManagerType> storageManager;

@end
