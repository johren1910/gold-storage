//
//  FileDBRepository.m
//  storage2
//
//  Created by LAP14885 on 06/07/2023.
//

#import <Foundation/Foundation.h>
#import "FileDBRepository.h"
#import "FileData.h"
#import <sqlite3.h>

static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface FileDBRepository ()
@property (nonatomic) NSString* databasePath;
@end

@implementation FileDBRepository

-(instancetype)initWithPath:(NSString*)path {
    if (self =[super init]) {
        self.databasePath = path;
    }
    return self;
}

- (id)getObjectWhere:(NSString*)where {
    return [self _getFileWhere:where];
}

- (NSArray *)getObjectsWhere:(NSString *)where {
    return nil;
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
    return [self _deleteFileData:object];
}

- (BOOL)save:(id)object {
    return [self _saveFileData:object];
}

- (BOOL)update:(id)object {
    return [self _updateFileData:object];
}

#pragma mark - Private methods

- (BOOL)_saveFileData:(FileData*) fileData {
    
    BOOL result = NO;
    const char *dbpath = [self.databasePath UTF8String];
    
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
    return result;
}

- (id) _getFileWhere:(NSString*)where {

    const char *dbpath = [self.databasePath UTF8String];
    FileData* result = nil;
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from file where %@ order by createdAt", where];
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
    return result;
}

- (BOOL)_deleteFileData:(FileData*) file {
    
    BOOL result = NO;
    const char *dbpath = [self.databasePath UTF8String];
    
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
    return result;
}

- (BOOL)_updateFileData:(FileData*) fileData {

    BOOL result = NO;
    const char *dbpath = [self.databasePath UTF8String];
    
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
    return result;
}

-(void)setDatabasePath:(NSString*)path {
    _databasePath = path;
}

@end

