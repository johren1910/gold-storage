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

@protocol DatabaseManagerType

#pragma mark - ChatMessage
- (BOOL)saveChatMessageData:(ChatMessageData*) chatMessage;
- (BOOL)deleteChatMessage:(ChatMessageData*) message;
- (NSArray<ChatMessageData*>*) getChatMessagesByRoomId:(NSString*)chatRoomId;
- (BOOL)updateChatMessage:(ChatMessageData*) chatMessage;

#pragma mark - ChatRoom
- (BOOL) saveChatRoomData:(ChatRoomModel*)chatRoom;
- (BOOL) deleteChatRoom:(ChatRoomModel*) chatRoom;
-(NSArray<ChatRoomModel*>*) getChatRoomsByPage:(int)page;

#pragma mark - File
- (BOOL)saveFileData:(FileData*) fileData;
- (BOOL)deleteFileData:(FileData*) file;
- (FileData*) getFileOfMessageId:(NSString*)messageId;

@end

@interface DatabaseManager : NSObject <DatabaseManagerType> {
   NSString *databasePath;
}

+(DatabaseManager*)getSharedInstance;

@end
