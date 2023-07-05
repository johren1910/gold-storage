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
@property (nonatomic, strong) dispatch_queue_t databaseQueue;
@property (nonatomic) NSUInteger currentUploadCount;
@property (nonatomic) NSUInteger maxUploadCount;
@property (nonatomic, strong) NSMutableArray *currentPendingUpload;
@property (strong,nonatomic) id<CacheServiceType> cacheService;
@property (strong,nonatomic) id<DatabaseManagerType> databaseManager;
@end

@implementation StorageManager

-(instancetype) initWithCacheService:(id<CacheServiceType>)cacheService andDatabaseManager:(id<DatabaseManagerType>)databaseManager {
    
    if (self == [super init]) {
        self.storageQueue = dispatch_queue_create("com.storagemanager.queue", DISPATCH_QUEUE_SERIAL);
        self.databaseQueue = dispatch_queue_create("com.storagemanager.database.queue", DISPATCH_QUEUE_SERIAL);
        self.cacheService = cacheService;
        self.databaseManager = databaseManager;
        self.currentUploadCount = 0;
        self.currentPendingUpload = [[NSMutableArray alloc]init];
        self.maxUploadCount = 10;
    }
    return self;
}

#pragma mark - DB Operation

- (void) createChatRoom:(ChatRoomModel*)chatRoom  completionBlock:(ZOCompletionBlock)completionBlock {
    
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        [weakself.databaseManager saveChatRoomData:chatRoom completionBlock:completionBlock];
    });
}

- (void)createChatMessage:(ChatMessageData*) chatMessage  completionBlock:(ZOCompletionBlock)completionBlock {
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
       ChatMessageDBRepository* messageDBRepository = [weakself.databaseManager getChatMessageDBRepository];
        BOOL result = [messageDBRepository save:chatMessage];
        completionBlock(result);
    });
}

- (void) getChatRoomsByPage:(int)page completionBlock:(ZOFetchCompletionBlock)completionBlock {
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        [weakself.databaseManager getChatRoomsByPage:page completionBlock:completionBlock];
    });
}

// 1 - Delete from DB
// 2 - Delete from cache
// 3 - Delete from local
// 4 - Delete file if still exist
// 5 - stop download of file
- (void)deleteChatMessage:(ChatMessageData*) message completionBlock:(ZOCompletionBlock)completionBlock {
    
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        ChatMessageDBRepository* messageDBRepository = [weakself.databaseManager getChatMessageDBRepository];
         BOOL result = [messageDBRepository remove:message];
        
        if (result) {
            [weakself.cacheService deleteImageByKey:message.file.checksum];
            [FileHelper removeItemAtPath:message.file.filePath];
            [weakself.databaseManager deleteFileData:message.file completionBlock:^(BOOL fileDeleted) {
                
            }];
            if(completionBlock)
                completionBlock(true);
        }
    });
}

- (void) getChatMessagesByRoomId:(NSString*)chatRoomId completionBlock:(ZOFetchCompletionBlock)completionBlock {
    
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        
        ChatMessageDBRepository* messageDBRepository = [weakself.databaseManager getChatMessageDBRepository];
        
        NSString* whereStr = [NSString stringWithFormat:@"chatRoomId=\"%@\"",chatRoomId];
        NSArray* objects = [messageDBRepository getObjectsWhere:whereStr];
        NSMutableArray* result = [[NSMutableArray alloc] init];
        for (int i=0; i<objects.count; i++) {
            
            ChatMessageData* messageData = (ChatMessageData*) objects[i];
            [result addObject:messageData];
        }
        completionBlock(result);
    });
}

- (void) getMessageOfId:(NSString*)messageId completionBlock:(ZOFetchCompletionBlock)completionBlock {
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        
        ChatMessageDBRepository* messageDBRepository = [weakself.databaseManager getChatMessageDBRepository];
        
        NSString* whereStr = [NSString stringWithFormat:@"messageId=\"%@\"",messageId];
        ChatMessageData* object = [messageDBRepository getObjectWhere:whereStr];
        completionBlock(object);
    });
}

/// 1 - Get all messages of room
/// 2 - Delete folder room
/// 3 - `deleteChatMessage` for each message
/// 4 - stop all download of Room
- (void)deleteChatRoom:(ChatRoomModel*) chatRoom completionBlock:(ZOCompletionBlock)completionBlock {
    
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        [weakself getChatMessagesByRoomId:chatRoom.chatRoomId completionBlock:^(id object){
            
            NSArray* messages = (NSArray*)object;
            [messages enumerateObjectsUsingBlock:^(ChatMessageData* obj, NSUInteger idx, BOOL *stop) {
                [weakself deleteChatMessage:obj completionBlock:^(BOOL isSuccess){
                    
                }];
            }];
        }];
        
        [weakself.databaseManager deleteChatRoom:chatRoom completionBlock:^(BOOL isSuccess){
            
            if (isSuccess) {
                NSString*folderPath = [FileHelper pathForApplicationSupportDirectoryWithPath:chatRoom.chatRoomId];
                [FileHelper removeItemAtPath:folderPath];
            }
        }];
    });
    
    completionBlock(TRUE);
}

- (void)compressThenCache: (UIImage*)image withKey:(NSString*) key {
    
    __weak StorageManager *weakself = self;
    dispatch_async(_storageQueue, ^{
        [CompressorHelper compressImage:image quality:Thumbnail completionBlock:^(UIImage* compressedImage){
            
            [weakself.cacheService cacheImageByKey:image withKey:key];
        }];
    });
}

- (void)createFile:(FileData*) fileData withNSData:(NSData*)data completionBlock:(ZOCompletionBlock)completionBlock {
    
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        if (data) {
            [weakself writeToFilePath:fileData.filePath withData:data];
        }
        [weakself.databaseManager saveFileData:fileData completionBlock:completionBlock];
    });
}
- (void)deleteFileData:(FileData*) file completionBlock:(ZOCompletionBlock)completionBlock {
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        [weakself.databaseManager deleteFileData:file completionBlock:completionBlock];
    });
}
- (void) getFileOfMessageId:(NSString*)messageId completionBlock:(ZOFetchCompletionBlock)completionBlock {
    
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        [weakself.databaseManager getFileOfMessageId:messageId completionBlock:completionBlock];
    });
    
}

- (void)updateFileData:(FileData*) fileData completionBlock:(ZOCompletionBlock)completionBlock {
    __weak StorageManager* weakself = self;
    dispatch_async(_databaseQueue, ^{
        [weakself.databaseManager updateFileData:fileData completionBlock:completionBlock];
    });
}

- (void) checkUploadPipeline {
    if(_currentUploadCount >= _maxUploadCount) {
        return;
    }
    
    if (_currentPendingUpload.count > 0) {
        ZOUploadUnit* unit = [_currentPendingUpload lastObject];
        [_currentPendingUpload removeLastObject];
        [self uploadImage:unit.data withRoomId:unit.roomID completionBlock:unit.completionBlock];
    }
    
}

- (void)uploadImage:(NSData*) data withRoomId:(NSString*)roomId completionBlock:(ZOFetchCompletionBlock)completionBlock {
    
    __weak StorageManager *weakself = self;
    
    if(_currentUploadCount >= _maxUploadCount) {
        
        ZOUploadUnit* unit = [[ZOUploadUnit alloc]init];
        unit.roomID = roomId;
        unit.data = data;
        unit.completionBlock = completionBlock;
        [_currentPendingUpload addObject:unit];
        return;
    }
    
    _currentUploadCount++;
    dispatch_async(_storageQueue, ^{
        NSString *checkSum = [HashHelper hashDataMD5:data];
        UIImage *temp = [weakself.cacheService getImageByKey:checkSum];
        if (!temp) {
            temp = [UIImage imageWithData:data];
            [weakself.cacheService cacheImageByKey:temp withKey:checkSum];
        }
        temp = nil;
        NSString *messageId = [[NSUUID UUID] UUIDString];
      
        double size = ((double)data.length/1024.0f)/1024.0f; // MB

        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:roomId];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.png", checkSum];
        
        //TODO: -DETECT NSDATA FILE TYPE
        NSString*folderName = [FileHelper getDefaultDirectoryByFileType:Picture];
        NSString *componentFolderPath = [folderName stringByAppendingPathComponent:fileName];
        NSString *filePath = [FileHelper pathForApplicationSupportDirectoryWithPath:componentFolderPath];
        
        newMessageData.createdAt = timeStamp;
        
        FileData *fileData = [[FileData alloc] init];
        fileData.fileId = [[NSUUID UUID] UUIDString];
        fileData.messageId = messageId;
        fileData.filePath = filePath;
        fileData.checksum = checkSum;
        fileData.createdAt = timeStamp;
        fileData.size = size;
        fileData.lastAccessed = timeStamp;
        fileData.lastModified = timeStamp;
        fileData.type = Picture;
        
        [weakself createChatMessage:newMessageData completionBlock:^(BOOL isSuccess){
            [weakself createFile:fileData withNSData:data completionBlock:^(BOOL isSaved){
                if (isSaved) {
                    newMessageData.file = fileData;
                    completionBlock(newMessageData);
                    weakself.currentUploadCount--;
                    [weakself checkUploadPipeline];
                }
            }];
        }];
    });
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
    FileType type = Unknown;
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

@implementation ZOUploadUnit


@end
