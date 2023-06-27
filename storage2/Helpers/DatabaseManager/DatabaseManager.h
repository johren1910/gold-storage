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

@interface DatabaseManager : NSObject {
   NSString *databasePath;
}

+(DatabaseManager*)getSharedInstance;
-(BOOL)createChatDatabase;
- (BOOL) saveChatRoomData:(ChatRoomModel*)chatRoome;
-(ChatRoomModel*) findChatsById:(NSString*)chatRoomId;
-(NSArray<ChatRoomModel*>*) getChatRoomsByPage:(int)page;
- (BOOL)saveChatMessageData:(ChatMessageData*) chatMessage totalRoomSize:(double)totalRoomSize;
- (NSArray<ChatMessageData*>*) getChatMessagesByRoomId:(NSString*)chatRoomId;
- (BOOL)updateChatMessage:(ChatMessageData*) chatMessage;

@end
