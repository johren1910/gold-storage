//
//  ChatDetailDataRepository.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatDetailDataRepository.h"
#import <UIKit/UIKit.h>

@interface ChatDetailDataRepository ()
@property (nonatomic) id<ChatDetailLocalDataSourceType> localDataSource;
@property (nonatomic) id<ChatDetailRemoteDataSourceType> remoteDataSource;
@property (nonatomic) id<StorageManagerType> storageManager;
@property (nonatomic) dispatch_queue_t backgroundQueue;
@end

@implementation ChatDetailDataRepository

- (void)getChatDataOfRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray<ChatDetailEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    __weak ChatDetailDataRepository* weakself = self;
    [_localDataSource getChatDataOfRoomId:roomId completionBlock:^(NSArray<ChatMessageData*>* chats) {
        NSMutableArray<ChatDetailEntity*>* results = [[NSMutableArray alloc] init];
        for (ChatMessageData* data in chats) {
            ChatDetailEntity* entity = [data toChatDetailEntity];
            
            UIImage* thumbnail = [weakself.storageManager getImageByKey:entity.file.checksum];
            if (!thumbnail && entity.file.filePath != nil) {

                if (entity.file.type == Video) {
                    ZOMediaInfo *mediaInfo = [FileHelper getMediaInfoOfFilePath:entity.file.filePath];
                    thumbnail = mediaInfo.thumbnail;
                    [weakself.storageManager compressThenCache:thumbnail withKey:entity.file.checksum];
                } else {
                    NSData *imageData = [NSData dataWithContentsOfFile:entity .file.filePath];
                    thumbnail = [UIImage imageWithData:imageData];
                }

            }
            entity.thumbnail = thumbnail;
            [results addObject:entity];
        }
        
        completionBlock([results copy]);
        }
                                    errorBlock:errorBlock];
}

- (void)saveChatMessage:(ChatMessageData*) chatMessage  completionBlock:(void(^)(ChatDetailEntity* entity))completionBlock {
    [_storageManager createChatMessage:chatMessage completionBlock:^(BOOL isSuccess) {
        completionBlock([chatMessage toChatDetailEntity]);
    }];
}

- (void)saveFile:(FileData*) fileData withNSData:(NSData*)data completionBlock:(void(^)(BOOL isSuccess))completionBlock {
    [_storageManager createFile:fileData withNSData:data completionBlock:^(BOOL isSuccess){
        completionBlock(isSuccess);
    }];
}

- (void)startDownloadWithUnit:(ZODownloadUnit*)unit
                   forMessage: (ChatMessageData*)message completionBlock:(void(^)(FileData* fileData, UIImage* thumbnail))completionBlock {
    __weak ChatDetailDataRepository* weakself = self;
    __weak ZODownloadUnit* weakunit = unit;
    unit.completionBlock = ^(NSString *filePath) {
        FileType fileType = [weakself.storageManager getFileTypeOfFilePath:filePath];
        NSString *currentFilePath = filePath;
        if (!weakunit.destinationDirectoryPath) {
            currentFilePath = [weakself _moveFileToGeneralFolders:filePath forFileType:fileType andSetName:[message.file.filePath lastPathComponent]];
        }
        message.messageState = Sent;
        [weakself updateMessageData:message completionBlock:^(BOOL isFinish){
            NSLog(@"updated");
        }];
        [weakself saveMedia:currentFilePath forMessage:message completionBlock:completionBlock];
        NSLog(@"destinationPath download: %@", currentFilePath);
    };
    
    unit.errorBlock = ^(NSError *error) {
        //        __block int index = -1;
        //        [weakself.messageModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //            ChatDetailEntity *currentModel = (ChatDetailEntity *)obj;
        //            if ([currentModel.messageData.messageId isEqualToString:messageId]) {
        //                index = idx;
        //                *stop = YES;
        //            }
        //        }];
        //        if (index == -1){
        //            return;
        //        }
        //        weakself.messageModels[index].isError = TRUE;
        //        weakself.filteredChats = weakself.messageModels;
        //
        //        dispatch_async( dispatch_get_main_queue(), ^{
        //            [self.delegate didUpdateObject:weakself.messageModels[index]];
        //        });
        NSLog(@"error");
    };
    
    [_remoteDataSource startDownloadWithUnit:unit];
}

- (NSString*)_moveFileToGeneralFolders:(NSString*) currentfilePath forFileType:(FileType)fileType andSetName:(NSString*)name {
    
    NSString* folderPath = [FileHelper getDefaultDirectoryByFileType:fileType];
    NSString* fileRelativePath = [folderPath stringByAppendingPathComponent:name];
    
    NSString* absolutePath = [FileHelper pathForApplicationSupportDirectoryWithPath:fileRelativePath];
    
    if ([FileHelper existsItemAtPath:absolutePath]) {
        return absolutePath;
    }
    [FileHelper createDirectoriesForFileAtPath:absolutePath];
    
    NSError *error;
    NSURL *srcUrl = [FileHelper urlForItemAtPath:currentfilePath];
    NSURL *dstUrl = [FileHelper urlForItemAtPath:absolutePath];
    [FileHelper copyItemAtPath:srcUrl toPath:dstUrl error:&error];
    [FileHelper removeItemAtPath:currentfilePath];
    return absolutePath;
}

- (void)saveMedia:(NSString*)filePath forMessage:(ChatMessageData*)message completionBlock:(void(^)(FileData* fileData, UIImage* thumbnail))completionBlock {
    __weak ChatDetailDataRepository* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        
        FileType fileType = [weakself.storageManager getFileTypeOfFilePath:filePath];
        NSData *fileData = [FileHelper readFileAtPathAsData:filePath];
        NSString *checkSum = [HashHelper hashDataMD5:fileData];
        UIImage *thumbnail = [weakself.storageManager getImageByKey:checkSum];
        double duration = 0;
        ZOMediaInfo *mediaInfo = nil;
        switch (fileType) {
            case Picture:
                if (!thumbnail) {
                    thumbnail = [UIImage imageWithData:fileData];
                    NSData* compressed = UIImageJPEGRepresentation(thumbnail, 0.5);
                    thumbnail = [UIImage imageWithData:compressed];
                    [weakself.storageManager compressThenCache:thumbnail withKey:checkSum];
                }
                
                break;
            case Video:
                mediaInfo = [FileHelper getMediaInfoOfFilePath:filePath];
                duration = mediaInfo.duration;
                if (!thumbnail) {
                    thumbnail = mediaInfo.thumbnail;
                    [weakself.storageManager compressThenCache:thumbnail withKey:checkSum];
                }
                
                break;
            default:
                break;
        }
        
        double size = ((double)fileData.length/1024.0f)/1024.0f; // MB
    
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        FileData *newFileData = [[FileData alloc] init];
        newFileData.checksum = checkSum;
        newFileData.fileName = [filePath lastPathComponent];
        newFileData.fileId = message.file.fileId;
        newFileData.messageId = message.messageId;
        newFileData.type = fileType;
        newFileData.size = size;
        newFileData.filePath = filePath;
        newFileData.createdAt = timeStamp;
        newFileData.duration = duration;
        
        [weakself updateFileData:newFileData completionBlock:^(BOOL isFinish){
            completionBlock(newFileData, thumbnail);
        }];
    });
}

- (void)deleteChatMessages:(NSArray<ChatDetailEntity*>*)messages completionBlock:(void(^)(BOOL isComplete))completionBlock {
    NSMutableArray<ChatMessageData*>* datas = [[NSMutableArray alloc] init];
    for (ChatDetailEntity* entity in messages) {
        ChatMessageData* messageData = [[ChatMessageData alloc] initWithMessage:entity.messageId messageId:entity.messageId chatRoomId:nil];
        messageData.file = entity.file;
        [datas addObject:messageData];
        [_remoteDataSource cancelDownloadOfUrl:entity.file.filePath];
    }
    
    [_localDataSource deleteChatMessages:[datas copy] completionBlock:completionBlock];
}

- (void)updateFileData:(FileData*) fileData completionBlock:(void(^)(BOOL isFinish))completionBlock {
    [_localDataSource updateFileData:fileData completionBlock:completionBlock];
}

- (void)updateMessageData:(ChatMessageData*) message completionBlock:(void(^)(BOOL isFinish))completionBlock {
    [_localDataSource updateMessageData:message completionBlock:completionBlock];
}

- (void) saveImageWithData:(NSData*)data ofRoomId:(NSString*)roomId completionBlock:(void(^)(ChatDetailEntity* entity)) completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    __weak ChatDetailDataRepository* weakself = self;
    [_storageManager uploadImage:data withRoomId:roomId completionBlock:^(id object) {
        ChatMessageData* data = (ChatMessageData*)object;
        ChatDetailEntity*entity = [data  toChatDetailEntity];
        entity.thumbnail = [weakself.storageManager getImageByKey:entity.file.checksum];
        completionBlock(entity);
    }];
}

- (void)getChatDataForMessageId:(NSString*)messageId completionBlock:(void (^)(ChatMessageData* chat))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    [_storageManager getMessageOfId:messageId completionBlock:^(id object){
        completionBlock((ChatMessageData*)object);
    }];
}

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [_storageManager cacheImageByKey:image withKey:key];
}

-(instancetype) initWithRemote:(id<ChatDetailRemoteDataSourceType>)remoteDataSource andLocal:(id<ChatDetailLocalDataSourceType>)localDataSource andStorageManager:(id<StorageManagerType>)storageManager {
    if (self == [super init]) {
        self.localDataSource = localDataSource;
        self.remoteDataSource = remoteDataSource;
        self.storageManager = storageManager;
        self.backgroundQueue = dispatch_queue_create("com.chatdetail.datarepository.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

@end
