//
//  DatabaseService.m
//  storage2
//
//  Created by LAP14885 on 17/06/2023.
//

#import "DatabaseService.h"
#import "FileHelper.h"
#import "ChatMessageDBRepository.h"
#import "ChatRoomDBRepository.h"

static DatabaseService *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

//TODO: Handle Retry when sql failed, db locked,..., retry 10 times,...

@interface DatabaseService ()
@property (nonatomic) NSString* databasePath;
@property (nonatomic) id<DBRepositoryInterface> chatMessageDBRepository;
@property (nonatomic) id<DBRepositoryInterface> chatRoomDBRepository;
@end

@implementation DatabaseService

+(DatabaseService*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance _createChatDatabase];
        [sharedInstance _createChatDetailDatabase];
        [sharedInstance _createFileDatabase];
    }
    return sharedInstance;
}

- (instancetype)init {
    if (self == [super init]) {
        
    }
    return self;
}

- (id<DBRepositoryInterface>) getChatMessageDBRepository {
    
    if (!_chatMessageDBRepository) {
        _chatMessageDBRepository = [[ChatMessageDBRepository alloc] init];
    }
   
    [_chatMessageDBRepository setDatabasePath:_databasePath];
    return _chatMessageDBRepository;
}

- (id<DBRepositoryInterface>) getChatRoomDBRepository {
    
    if (!_chatRoomDBRepository) {
        _chatRoomDBRepository = [[ChatRoomDBRepository alloc] init];
    }
   
    [_chatRoomDBRepository setDatabasePath:_databasePath];
    return _chatRoomDBRepository;
}

#pragma mark - initialization

-(BOOL)_createChatDatabase {
    
    _databasePath = [FileHelper pathForApplicationSupportDirectoryWithPath:@"chat.db"];

    NSLog(@"Database path: %@", _databasePath);
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    // Create ChatRoom table
    if ([filemgr fileExistsAtPath: _databasePath ] == NO) {
        const char *dbpath = [_databasePath UTF8String];
        if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt =
            "create table if not exists chatRoom (chatRoomId text primary key, name text, size real, createdAt real)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close_v2(database);
    return isSuccess;
}

-(BOOL)_createChatDetailDatabase {
    NSString *dirPath = [FileHelper pathForApplicationSupportDirectory];

    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString:
                    [dirPath stringByAppendingPathComponent: @"chat.db"]];
    BOOL isSuccess = YES;
    
    // Create ChatMessage table
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK) {
        char *errMsg;
        const char *sql_stmt =
        "create table if not exists chatMessage (messageId text primary key, message text, chatRoomId text, createdAt real, state int)";
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
            isSuccess = NO;
            NSLog(@"Failed to create table");
        }
    } else {
        isSuccess = NO;
        NSLog(@"Failed to open/create database");
    }
    sqlite3_close_v2(database);
    return isSuccess;
}

-(BOOL)_createFileDatabase {
    
    NSString *dirPath = [FileHelper pathForApplicationSupportDirectory];

    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString:
                    [dirPath stringByAppendingPathComponent: @"chat.db"]];
    BOOL isSuccess = YES;
    
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK) {
        char *errMsg;
        const char *sql_stmt =
        "create table if not exists file (id text primary key, messageId text, fileName text, filePath text, checksum text, createdAt real, size real, duration real, lastModified real, lastAccessed real, type int)";
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
            isSuccess = NO;
            NSLog(@"Failed to create table");
        }
    } else {
        isSuccess = NO;
        NSLog(@"Failed to open/create database");
    }
    sqlite3_close_v2(database);
    return isSuccess;
}

- (void)saveFileData:(FileData*) fileData completionBlock:(ZOCompletionBlock)completionBlock {
    
    __weak DatabaseService* weakself = self;
    BOOL result = NO;
    const char *dbpath = [weakself.databasePath UTF8String];
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into file (id, messageId, fileName, filePath, checksum, createdAt, size, duration, lastModified, lastAccessed, type) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%lf, %lf,%lf,%lf,%lf,%ld)", fileData.fileId, fileData.messageId, fileData.fileName, fileData.filePath, fileData.checksum,
                               fileData.createdAt,
                               fileData.size,
                               fileData.duration,
                               fileData.lastModified,
                               fileData.lastAccessed,
                               (long)fileData.type];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int code = sqlite3_step(statement);
        if (code == SQLITE_DONE) {
            result = YES;
        } else {
            result = NO;
        }
        sqlite3_finalize(statement);
    }
    
    sqlite3_close_v2(database);
    completionBlock(result);
}

- (void) getFileOfMessageId:(NSString*)messageId completionBlock:(ZOFetchCompletionBlock)completionBlock {
    
    __weak DatabaseService* weakself = self;
    const char *dbpath = [weakself.databasePath UTF8String];
    FileData* result = nil;
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from file where messageId =\"%@\" order by createdAt", messageId];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement)==SQLITE_ROW)
            {
                FileData *file = [[FileData alloc] init];
                file.fileId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                file.messageId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                file.fileName = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                file.filePath = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
                file.checksum = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                
                file.createdAt =  sqlite3_column_double(statement, 5);
                file.size =  sqlite3_column_double(statement, 6);
                file.duration =  sqlite3_column_double(statement, 7);
                file.lastModified =  sqlite3_column_double(statement, 8);
                file.lastAccessed =  sqlite3_column_double(statement, 9);
                file.type = sqlite3_column_int(statement, 10);
                result = file;
                
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close_v2(database);
    completionBlock(result);
}

- (void)deleteFileData:(FileData*) file completionBlock:(ZOCompletionBlock)completionBlock {
    
    __weak DatabaseService* weakself = self;
    BOOL result = NO;
    const char *dbpath = [weakself.databasePath UTF8String];
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from file where id =\"%@\"",
                               file.fileId];
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
    completionBlock(result);
}

- (void)updateFileData:(FileData*) fileData completionBlock:(ZOCompletionBlock)completionBlock {
    
    __weak DatabaseService* weakself = self;
    BOOL result = NO;
    const char *dbpath = [weakself.databasePath UTF8String];
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        
        NSString *updateSQL = [NSString stringWithFormat:@"update file set fileName=\"%@\", filePath=\"%@\", checksum=\"%@\", createdAt=%lf, size=%lf,duration=%lf,lastModified=%lf, type = %ld where id =\"%@\"", fileData.fileName,
                               fileData.filePath,
                               fileData.checksum,
                               fileData.createdAt,
                               fileData.size,
                               fileData.duration,
                               fileData.lastModified,
                               fileData.type,
                               fileData.fileId];
        const char *stmt = [updateSQL UTF8String];
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
    completionBlock(result);
}

- (void) getChatMessageIdsByRoomId:(NSString*)chatRoomId completionBlock:(ZOFetchCompletionBlock)completionBlock {
    
    __weak DatabaseService* weakself = self;
    const char *dbpath = [weakself.databasePath UTF8String];
    NSMutableArray<NSString*>* result = [@[] mutableCopy] ;
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select messageId from chatMessage where chatRoomId=\"%@\" order by createdAt DESC ", chatRoomId];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                NSString *messageId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
              
                [result addObject:messageId];
              
            }
            
            sqlite3_finalize(statement);
            sqlite3_close_v2(database);
            completionBlock(result);
            return;
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close_v2(database);
    completionBlock(nil);
}

@end
