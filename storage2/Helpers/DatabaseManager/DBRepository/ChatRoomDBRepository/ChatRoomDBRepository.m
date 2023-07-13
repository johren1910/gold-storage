//
//  ChatRoomDBRepository.m
//  storage2
//
//  Created by LAP14885 on 06/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomDBRepository.h"
#import "ChatRoomData.h"
#import <sqlite3.h>

static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface ChatRoomDBRepository ()
@property (nonatomic) NSString* databasePath;
@end

@implementation ChatRoomDBRepository

-(instancetype)initWithPath:(NSString*)path {
    if (self =[super init]) {
        self.databasePath = path;
    }
    return self;
}

- (id)getObjectWhere:(NSString*)where {
    return nil;
//    return [self _getMessageWhere:where];
}

- (NSArray*)getObjectsWhere:(NSString*)where isDistinct:(BOOL)isDistinct {
    return [self _getChatRoomsByPage:1];
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
    return [self _deleteChatRoom:object];
}

- (BOOL)save:(id)object {
    return [self _saveChatRoomData:object];
}

- (BOOL)update:(id)object {
    return false;
}

#pragma mark - Private methods
- (BOOL)_deleteChatRoom:(ChatRoomData*)chatRoom {
    
    BOOL result = NO;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from chatRoom where chatRoomId =\"%@\"",
                               chatRoom.chatRoomId];
        const char *stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, stmt,-1, &statement, NULL);
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

- (BOOL)_saveChatRoomData:(ChatRoomData*)chatRoom {
    
    BOOL result = NO;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into chatRoom (chatRoomId,name, createdAt, size) values (\"%@\",\"%@\", %f, %d)",chatRoom.chatRoomId, chatRoom.name, chatRoom.createdAt, 0];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            result = YES;
        } else {
            result = NO;
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close_v2(database);
    return result;
}

- (NSArray*)_getChatRoomsByPage:(int)page {
    
    const char *dbpath = [self.databasePath UTF8String];
    int limit = page * 100;
    NSMutableArray<ChatRoomData*>* result = [@[] mutableCopy] ;
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from chatRoom order by createdAt DESC limit %d ", limit];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                ChatRoomData *chat = [[ChatRoomData alloc] init];
                chat.chatRoomId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                chat.name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                chat.createdAt =  sqlite3_column_double(statement, 2);
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

-(void)setDatabasePath:(NSString*)path {
    _databasePath = path;
}

@end
