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
#import "FileDBRepository.h"

static DatabaseService *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

//TODO: Handle Retry when sql failed, db locked,..., retry 10 times,...

@interface DatabaseService ()
@property (nonatomic) NSString* databasePath;
@property (nonatomic) id<DBRepositoryInterface> chatMessageDBRepository;
@property (nonatomic) id<DBRepositoryInterface> chatRoomDBRepository;
@property (nonatomic) id<DBRepositoryInterface> fileDBRepository;
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

- (id<DBRepositoryInterface>) getFileDBRepository {
    
    if (!_fileDBRepository) {
        _fileDBRepository = [[FileDBRepository alloc] init];
    }
   
    [_fileDBRepository setDatabasePath:_databasePath];
    return _fileDBRepository;
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

@end
