//
//  ChatDetailReporitoryInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//
#import "ChatDetailEntity.h"
#import "ChatMessageData.h"
#import "ZODownloadManagerType.h"

@protocol ChatDetailRepositoryInterface

- (void)getChatDataOfRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray<ChatDetailEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void) saveImageWithData:(NSData*)data ofRoomId:(NSString*)roomId completionBlock:(void(^)(ChatDetailEntity* entity)) completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)getChatDataForMessageId:(NSString*)messageId completionBlock:(void (^)(ChatMessageData* chat))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)saveChatMessage:(ChatMessageData*) chatMessage  completionBlock:(void(^)(ChatDetailEntity* entity))completionBlock;
- (void)saveFile:(FileData*) fileData withNSData:(NSData*)data completionBlock:(void(^)(BOOL isSuccess))completionBlock;

- (void)saveMedia:(NSString*)filePath forMessage:(ChatMessageData*)message completionBlock:(void(^)(FileData* fileData, UIImage* thumbnail))completionBlock;

- (void)deleteChatMessages:(NSArray<ChatDetailEntity*>*)messages completionBlock:(void(^)(BOOL isComplete))completionBlock;

- (void)updateFileData:(FileData*) fileData completionBlock:(void(^)(BOOL isFinish))completionBlock;

- (void)startDownloadWithUnit:(ZODownloadUnit*)unit;

@end
