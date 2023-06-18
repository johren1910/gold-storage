//
//  DatabaseManager.m
//  storage2
//
//  Created by LAP14885 on 17/06/2023.
//

#import "DatabaseManager.h"
static DatabaseManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DatabaseManager

+(DatabaseManager*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createChatDatabase];
    }
    return sharedInstance;
}

-(BOOL)createChatDatabase {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"chat.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt =
            "create table if not exists chatRoom (chatId integer primary key, name text)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

-(BOOL)createChatDetailDatabase {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"chat.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt =
            "create table if not exists chat (chatId integer primary key, name text)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}


- (BOOL) saveChatRoomData:(NSString*)chatId name:(NSString*)name; {
    
    BOOL result = NO;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into chatRoom (chatId,name) values (\"%@\",\"%@\")",chatId, name];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            result = YES;
        } else {
            result = NO;
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return result;
}

- (ChatRoomModel*) findChatById:(NSString*)chatId {
    const char *dbpath = [databasePath UTF8String];
    
    ChatRoomModel* result = nil;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select chatId, name from chatRoom where chatId=\"%@\"",chatId];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *chatId = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)];

                
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 1)];
                
                
                result = [[ChatRoomModel alloc] initWithName:name chatId:chatId];
                
            } else {
                NSLog(@"Not found");
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
            
            return result;
        }
    }
    return nil;
}

- (NSArray<ChatRoomModel*>*) getChatsByPage:(int)page; {
    const char *dbpath = [databasePath UTF8String];
    int limit = page * 10;
    NSMutableArray<ChatRoomModel*>* result = [@[] mutableCopy] ;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from chatRoom order by chatId DESC limit %d ", limit];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                ChatRoomModel *chat = [[ChatRoomModel alloc] init];
                chat.chatId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                chat.name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                [result addObject:chat];
                chat = nil;
            }
           
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                
  
            } else {
                NSLog(@"Not found");
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return result;
        }
    }
    return nil;
}

@end
