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
-(BOOL) createChatDatabase;
- (BOOL) saveChatRoomData:(ChatRoomModel*)chatRoome;
-(ChatRoomModel*) findChatsById:(NSString*)chatRoomId;
-(NSArray<ChatRoomModel*>*) getChatRoomsByPage:(int)page;
- (BOOL)saveChatMessageData:(ChatMessageData*) chatMessage totalRoomSize:(double)totalRoomSize;
- (BOOL)deleteChatMessage:(ChatMessageData*) message;
- (NSArray<ChatMessageData*>*) getChatMessagesByRoomId:(NSString*)chatRoomId;
- (BOOL)updateChatMessage:(ChatMessageData*) chatMessage;
- (BOOL)deleteChatRoom:(ChatRoomModel*) chatRoom;
@end

@interface DatabaseManager : NSObject <DatabaseManagerType> {
   NSString *databasePath;
}

+(DatabaseManager*)getSharedInstance;

@end
