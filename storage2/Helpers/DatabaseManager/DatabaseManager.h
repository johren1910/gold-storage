//
//  DatabaseManager.h
//  storage2
//
//  Created by LAP14885 on 17/06/2023.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ChatRoomModel.h"
#import "FileData.h"

typedef void(^ZOCompletionBlock)(BOOL isSuccess);
typedef void(^ZOFetchCompletionBlock)(id object);

@protocol DatabaseManagerType

#pragma mark - ChatMessage
- (void)saveChatMessageData:(ChatMessageData*) chatMessage  completionBlock:(ZOCompletionBlock)completionBlock;
- (void)deleteChatMessage:(ChatMessageData*) message completionBlock:(ZOCompletionBlock)completionBlock;
- (void) getChatMessagesByRoomId:(NSString*)chatRoomId completionBlock:(ZOFetchCompletionBlock)completionBlock;
- (void) getMessageOfId:(NSString*)messageId completionBlock:(ZOFetchCompletionBlock)completionBlock;

#pragma mark - ChatRoom
- (void) saveChatRoomData:(ChatRoomModel*)chatRoom completionBlock:(ZOCompletionBlock)completionBlock;
- (void)deleteChatRoom:(ChatRoomModel*) chatRoom completionBlock:(ZOCompletionBlock)completionBlock;
- (void) getChatRoomsByPage:(int)page completionBlock:(ZOFetchCompletionBlock)completionBlock;
- (void)getSizeOfRoomId:(NSString*) roomId completionBlock:(ZOFetchCompletionBlock)completionBlock;

#pragma mark - File
- (void)saveFileData:(FileData*) fileData completionBlock:(ZOCompletionBlock)completionBlock;
- (void)deleteFileData:(FileData*) file completionBlock:(ZOCompletionBlock)completionBlock;
- (void) getFileOfMessageId:(NSString*)messageId completionBlock:(ZOFetchCompletionBlock)completionBlock;
- (void)updateFileData:(FileData*) fileData completionBlock:(ZOCompletionBlock)completionBlock;

@end

@interface DatabaseManager : NSObject <DatabaseManagerType>


+(DatabaseManager*)getSharedInstance;

@end
