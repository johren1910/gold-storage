//
//  DatabaseManager.h
//  storage2
//
//  Created by LAP14885 on 17/06/2023.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ChatModel.h"

@interface DatabaseManager : NSObject {
   NSString *databasePath;
}

+(DatabaseManager*)getSharedInstance;
-(BOOL)createChatDatabase;
-(BOOL) saveChatData:(NSString*)chatId name:(NSString*)name;
-(ChatModel*) findChatsById:(NSString*)chatId;
-(NSArray<ChatModel*>*) getChatsByPage:(int)page;

@end
