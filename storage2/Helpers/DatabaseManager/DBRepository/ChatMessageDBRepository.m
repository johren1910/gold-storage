//
//  ChatMessageDBRepository.m
//  storage2
//
//  Created by LAP14885 on 05/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatMessageDBRepository.h"
#import "ChatMessageData.h"
#import <sqlite3.h>

static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface ChatMessageDBRepository ()
@property (nonatomic) NSString* databasePath;
@end

@implementation ChatMessageDBRepository

-(instancetype)initWithPath:(NSString*)path {
    if (self =[super init]) {
        self.databasePath = path;
    }
    return self;
}

- (id)getObjectWhere:(NSString*)where {
    return [self _getMessageWhere:where];
}

- (NSArray *)getObjectsWhere:(NSString *)where {
    return [self _getChatMessagesWhere:where];
}

- (NSArray *)getObjectsWhere:(NSString *)where orderBy:(NSString *)orderByAttribute ascending:(BOOL)ascending {
    return nil;
}

- (NSArray *)getObjectsWhere:(NSString *)where orderBy:(NSString *)orderByAttribute ascending:(BOOL)ascending take:(int)countItem {
    return nil;
}

- (NSArray *)getObjectsWhere:(NSString *)where take:(int)countItem {
    return nil;
}

- (BOOL)remove:(id)object {
    ChatMessageData* data = (ChatMessageData*)object;
    return [self _deleteChatMessage:data];
}

- (BOOL)save:(id)object {
    ChatMessageData* data = (ChatMessageData*)object;
    return [self _saveChatMessageData:data];
}

#pragma mark - Private methods
- (BOOL)_deleteChatMessage:(ChatMessageData*) message {
    
    BOOL result = NO;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from chatMessage where messageId =\"%@\"",
                               message.messageId];
        const char *stmt = [deleteSQL UTF8String];
        int prepare = sqlite3_prepare_v2(database, stmt,-1, &statement, NULL);
        if (prepare != SQLITE_OK) {
           NSString* errorMsg = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            NSLog(@"%@", errorMsg);
        }
        int code = sqlite3_step(statement);
        if (code == SQLITE_DONE) {
            result = YES;
        } else {
            result = NO;
        }
        sqlite3_finalize(statement);
    }
    
    sqlite3_close_v2(database);
    return result;
}

- (BOOL)_saveChatMessageData:(ChatMessageData*) chatMessage {
    BOOL result = NO;
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into chatMessage (messageId, message, chatRoomId, createdAt) values (\"%@\",\"%@\",\"%@\",%lf)", chatMessage.messageId, chatMessage.message, chatMessage.chatRoomId, chatMessage.createdAt];
        const char *insert_stmt = [insertSQL UTF8String];
        int prepare = sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (prepare != SQLITE_OK) {
           NSString* errorMsg = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            NSLog(@"%@", errorMsg);
        }
        int code = sqlite3_step(statement);
        if (code == SQLITE_DONE) {
            result = YES;
        } else {
            result = NO;
        }
        sqlite3_finalize(statement);
    }

    sqlite3_close_v2(database);
    return result;
}

- (NSArray*) _getChatMessagesWhere:(NSString*)where {
    const char *dbpath = [_databasePath UTF8String];
    NSMutableArray<ChatMessageData*>* result = [@[] mutableCopy] ;
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select chatMessage.messageId, message, chatRoomId, chatMessage.createdAt, id, filePath, checkSum, size, duration, type from chatMessage left join file on chatMessage.messageId = file.messageId where %@ order by chatMessage.createdAt DESC", where];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                // Message data
                NSString *messageId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                NSString *message = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                
                NSString *chatRoomId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                double createdAt = (double) sqlite3_column_double(statement, 3);
                
                // File data
                NSString *fileId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                NSString *filePath = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                
                NSString *checkSum = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 6)];
                double size = (double) sqlite3_column_double(statement, 7);
                double duration = (double) sqlite3_column_double(statement, 8);
                int fileType = (int) sqlite3_column_int(statement, 9);
                
                FileData *fileData = [[FileData alloc] init];
                fileData.fileId = fileId;
                fileData.messageId = messageId;
                fileData.filePath = filePath;
                fileData.checksum = checkSum;
                fileData.size = size;
                fileData.duration = duration;
                fileData.type = fileType;
                
                ChatMessageData *chat = [[ChatMessageData alloc] initWithMessage:message messageId:messageId chatRoomId:chatRoomId];
                chat.createdAt = createdAt;
                chat.file = fileData;
              
                [result addObject:chat];
                chat = nil;
            }
            
            sqlite3_finalize(statement);
            sqlite3_close_v2(database);
            return result;
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close_v2(database);
    return nil;
}

- (id) _getMessageWhere:(NSString*)where {
    const char *dbpath = [_databasePath UTF8String];
    ChatMessageData* result = nil;
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select chatMessage.messageId, message, chatRoomId, chatMessage.createdAt, id, filePath, checkSum, size, duration, type from chatMessage left join file on chatMessage.messageId = file.messageId where %@ order by chatMessage.createdAt DESC", where];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement)==SQLITE_ROW)
            {
                // Message data
                NSString *messageId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                NSString *message = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                
                NSString *chatRoomId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                double createdAt = (double) sqlite3_column_double(statement, 3);
                
                // File data
                NSString *fileId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                NSString *filePath = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 5)];
                
                NSString *checkSum = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 6)];
                double size = (double) sqlite3_column_double(statement, 7);
                double duration = (double) sqlite3_column_double(statement, 8);
                int fileType = (int) sqlite3_column_int(statement, 9);
                
                FileData *fileData = [[FileData alloc] init];
                fileData.fileId = fileId;
                fileData.messageId = messageId;
                fileData.filePath = filePath;
                fileData.checksum = checkSum;
                fileData.size = size;
                fileData.duration = duration;
                fileData.type = fileType;
                
                ChatMessageData *chat = [[ChatMessageData alloc] initWithMessage:message messageId:messageId chatRoomId:chatRoomId];
                chat.createdAt = createdAt;
                chat.file = fileData;
              
                result = chat;
                chat = nil;
            }
            
            sqlite3_finalize(statement);
            sqlite3_close_v2(database);
            return result;
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close_v2(database);
    return nil;
}

-(void)setDatabasePath:(NSString*)path {
    _databasePath = path;
}

@end
