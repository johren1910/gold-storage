//
//  StorageManager.m
//  storage2
//
//  Created by LAP14885 on 27/06/2023.
//

#import <Foundation/Foundation.h>
#import "StorageManager.h"
#import "ChatMessageData.h"
#import "CompressorHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface StorageManager ()
@property (nonatomic, strong) dispatch_queue_t storageQueue;
@end

@implementation StorageManager

-(instancetype) initWithCacheService:(id<CacheServiceType>)cacheService andDatabaseManager:(id<DatabaseManagerType>)databaseManager {
    
    if (self == [super init]) {
        self.storageQueue = dispatch_queue_create("com.storagemanager.queue", DISPATCH_QUEUE_SERIAL);
        self.cacheService = cacheService;
        self.databaseManager = databaseManager;
    }
    return self;
}

#pragma mark - DB Operation

- (BOOL) saveChatRoomData:(ChatRoomModel*)chatRoom {
    return [_databaseManager saveChatRoomData:chatRoom];
}

- (BOOL)saveChatMessageData:(ChatMessageData*) chatMessage {
    return [_databaseManager saveChatMessageData:chatMessage];
}

-(NSArray<ChatRoomModel*>*) getChatRoomsByPage:(int)page {
    return [_databaseManager getChatRoomsByPage:page];
}

// 1 - Delete from DB
// 2 - Delete from cache
// 3 - Delete from local
// 4 - Delete file
- (BOOL)deleteChatMessage:(ChatMessageData*) message {
   BOOL dbDeleted = [_databaseManager deleteChatMessage:message];
    [_cacheService deleteImageByKey:message.messageId];
    [FileHelper removeItemAtPath:message.file.filePath];
    [_databaseManager deleteFileData:message.file];
    return dbDeleted;
}

- (NSArray<ChatMessageData*>*) getChatMessagesByRoomId:(NSString*)chatRoomId {
    NSArray<ChatMessageData*>* result = [_databaseManager getChatMessagesByRoomId:chatRoomId];
    
    for (ChatMessageData* message in result) {
        message.file = [self getFileOfMessageId:message.messageId];
    }
    return result;
}

- (BOOL)updateFileData:(FileData *)fileData {
    return [_databaseManager updateFileData:fileData];
}

/// 1 - Get all messages of room
/// 2 - `deleteChatMessage` for each message
/// 3 - Delete room
- (BOOL)deleteChatRoom:(ChatRoomModel*) chatRoom {
    
    __weak StorageManager* weakself = self;
    dispatch_async(_storageQueue, ^(){
        [[weakself getChatMessagesByRoomId:chatRoom.chatRoomId] enumerateObjectsUsingBlock:^(ChatMessageData* obj, NSUInteger idx, BOOL *stop) {
            [weakself deleteChatMessage:obj];
        }];
        [weakself.databaseManager deleteChatRoom:chatRoom];
    });
    
    return TRUE;
}

- (double)getSizeOfRoomId:(NSString*) roomId {
    return [_databaseManager getSizeOfRoomId:roomId];
}

- (void)compressThenCache: (UIImage*)image withKey:(NSString*) key {
    
    __weak StorageManager *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cache.image", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        [CompressorHelper compressImage:image quality:Thumbnail completionBlock:^(UIImage* compressedImage){
            
            [weakself.cacheService cacheImageByKey:image withKey:key];
        }];
    });
}

- (BOOL)saveFileData:(FileData*) fileData {
    if (fileData.tempData) {
        [self writeToFilePath:fileData.filePath withData:fileData.tempData];
        
        UIImage *image = [UIImage imageWithData:fileData.tempData];
        if (image) {
            [self compressThenCache:image withKey:fileData.messageId];
        }
    }
    return [_databaseManager saveFileData:fileData];
}
- (BOOL)deleteFileData:(FileData*) file {
    return [_databaseManager deleteFileData:file];
}
- (FileData*) getFileOfMessageId:(NSString*)messageId {
    return [_databaseManager getFileOfMessageId:messageId];
}

#pragma mark - Local file operation
-(void)writeToFilePath:(NSString*)filePath withData:(NSData*)data {
    [FileHelper createDirectoriesForFileAtPath:filePath];
    [data writeToFile:filePath atomically:YES];
}

# pragma mark - Cache Operation
-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key {
    [_cacheService cacheImageByKey:image withKey:key];
}
-(UIImage*)getImageByKey:(NSString*)key {
    return [_cacheService getImageByKey:key];
}
-(void)deleteImageByKey:(NSString*)key {
    [_cacheService deleteImageByKey:key];
}

# pragma mark - Helper Operation
-(FileType)getFileTypeOfFilePath:(NSString*)filePath {
    FileType type = Uknown;
    CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        type = Picture;
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
        type = Video;
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
        NSLog(@"Text type");
    }
    CFRelease(fileUTI);
    return type;
}

@end
