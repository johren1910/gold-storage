//
//  DatabaseManager.h
//  storage2
//
//  Created by LAP14885 on 17/06/2023.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ChatRoomModel.h"

@interface DatabaseManager : NSObject {
   NSString *databasePath;
}

+(DatabaseManager*)getSharedInstance;
-(BOOL)createChatDatabase;
-(BOOL) saveChatRoomData:(NSString*)chatId name:(NSString*)name;
-(ChatRoomModel*) findChatsById:(NSString*)chatId;
-(NSArray<ChatRoomModel*>*) getChatsByPage:(int)page;

@end
