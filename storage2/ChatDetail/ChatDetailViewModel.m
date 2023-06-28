//
//  ChatDetailViewModel.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailViewModel.h"
#import "ChatMessageData.h"
#import "ChatMessageModel.h"
#import "FileType.h"
#import "FileHelper.h"
#import "HashHelper.h"
#import "CompressorHelper.h"
#import <objc/runtime.h>

@interface ChatDetailViewModel ()
@property (retain,nonatomic) NSMutableArray<ChatMessageModel *> *messageModels;
@property (retain,nonatomic) NSMutableArray<ChatMessageModel *> *selectedModels;
@property (nonatomic, copy) ChatRoomModel *chatRoom;
@end

@implementation ChatDetailViewModel

-(instancetype) initWithChatRoom: (ChatRoomModel*) chatRoom {
    self = [super init];
    if (self) {
        self.messageModels = [[NSMutableArray alloc] init];
        self.selectedModels = [[NSMutableArray alloc] init];
    }
    _chatRoom = chatRoom;
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messageModels = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)getData:(void (^)(NSArray<ChatMessageModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    __weak ChatDetailViewModel *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.chat.data", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        NSArray<ChatMessageData*>* result = [weakself.storageManager getChatMessagesByRoomId:weakself.chatRoom.chatRoomId];
        
        if (result != nil) {
            
            NSMutableArray<ChatMessageModel*>* modelResult = [@[] mutableCopy];
            
            for (ChatMessageData* messageData in result) {
                
                UIImage* cachedImage = [weakself.storageManager getImageByKey:messageData.messageId];
                
                ChatMessageModel* model = [[ChatMessageModel alloc] initWithMessageData:messageData thumbnail:cachedImage];
                
                [modelResult addObject:model];
                
                if (messageData.file.type == Download) {
                    [weakself requestDownloadWithUrl:messageData.file.filePath forFileId:messageData.file.fileId andMessageId:messageData.messageId];
                }
            }
            weakself.messageModels = [modelResult mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.filteredChats = weakself.messageModels;
                successCompletion(weakself.messageModels);
            });
        }
    });
}

- (ChatMessageModel *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.filteredChats.count) {
        return nil;
    }
    
    return self.filteredChats[indexPath.row];
}

- (void)changeSegment: (NSInteger) index {
    __weak ChatDetailViewModel *weakself = self;
    if (index == 0) {
        _filteredChats = _messageModels;
        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
        return;
    }
    
    NSString *predicateString = @"messageData.file.type =[c] %ld";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, index];
    
    if (index == 1) {
         predicate = [NSPredicate predicateWithFormat:predicateString, Picture];
    } else if (index == 2) {
         predicate = [NSPredicate predicateWithFormat:predicateString, Video];
    }
    
    NSArray *filteredArray = [_messageModels filteredArrayUsingPredicate:predicate];
    _filteredChats = filteredArray;
   
    dispatch_async( dispatch_get_main_queue(), ^{
        [weakself.delegate didUpdateData];
    });
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSArray<ChatMessageModel*>*) items {
    return _filteredChats;
}

- (void)downloadFileWithUrl:(NSString *)url {
    
    __weak ChatDetailViewModel* weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_SERIAL);
    dispatch_async(myQueue, ^{
        NSString *messageId = [[NSUUID UUID] UUIDString];
        NSString *fileId = [[NSUUID UUID] UUIDString];
        
        ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:weakself.chatRoom.chatRoomId];
        
        FileData *newFileData = [[FileData alloc] init];
        newFileData.type = Download;
        newFileData.fileId = fileId;
        newFileData.messageId = messageId;
        
        newMessageData.file = newFileData;
        
        ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:nil];
        
        [weakself.messageModels insertObject:newModel atIndex:0];
        weakself.filteredChats = weakself.messageModels;

        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
        
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
       
        newFileData.filePath = url;
        newMessageData.createdAt = timeStamp;
        newFileData.createdAt = timeStamp;
        
        [weakself.storageManager saveChatMessageData:newMessageData];
        [weakself.storageManager saveFileData:newFileData];
        
        [weakself requestDownloadWithUrl:url forFileId:fileId andMessageId:messageId];
    });
    
}

- (void)requestDownloadWithUrl:(NSString *)url forFileId:(NSString*) fileId andMessageId:(NSString*)messageId {
    
    NSString *chatRoomName = self.chatRoom.chatRoomId;
    NSString *folderPath = [FileHelper documentsPathForFileName:chatRoomName];

    __weak ChatDetailViewModel* weakself = self;

    [_downloadManager startDownloadWithUrl:url destinationDirectory:folderPath isBackgroundDownload: FALSE progressBlock:^(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds) {

        NSLog(@"progress: %f\nspeed: %ld\nremainSeconds:%ld", progress,speed,remainingSeconds);

    } completionBlock:^(NSString *destinationPath) {

        [weakself addDownloadedMedia:destinationPath withFileId:fileId andMessageId:messageId];
        NSLog(@"destinationPath download: %@", destinationPath);
    } errorBlock:^(NSError *error) {

    }];
}

- (void)addDownloadedMedia:(NSString *)filePath withFileId:(NSString*)fileId andMessageId:(NSString*)messageId {
    __weak ChatDetailViewModel *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_SERIAL);
    dispatch_async(myQueue, ^{
        
        NSData *fileData = [FileHelper readFileAtPathAsData:filePath];

        ZOMediaInfo *mediaInfo = [FileHelper getMediaInfoOfFilePath:filePath];
        
        UIImage *thumbnail = mediaInfo.thumbnail;
        NSString *checkSum = [HashHelper hashDataMD5:fileData];
        [weakself.storageManager compressThenCache:thumbnail withKey:messageId];
        
        double size = ((double)fileData.length/1024.0f)/1024.0f; // MB
    
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        FileData *newFileData = [[FileData alloc] init];
        newFileData.checksum = checkSum;
        newFileData.fileName = [filePath lastPathComponent];
        newFileData.fileId = fileId;
        newFileData.messageId = messageId;
        newFileData.type = [weakself.storageManager getFileTypeOfFilePath:filePath];
        newFileData.size = size;
        newFileData.filePath = filePath;
        newFileData.createdAt = timeStamp;
        newFileData.duration = mediaInfo.duration;
        
        [[weakself storageManager] updateFileData:newFileData];

        __block ChatMessageData *messageData = nil;
        __block NSUInteger index = 0;
        [weakself.messageModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ChatMessageModel *model = (ChatMessageModel *)obj;
            if ([model.messageData.messageId isEqualToString:messageId]) {
                index = idx;
                *stop = YES;
                messageData = [model.messageData copy];
            }
            
        }];
        
        messageData.file = newFileData;
        ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:messageData thumbnail:thumbnail];
        
        [weakself.messageModels replaceObjectAtIndex:index withObject:newModel];
        weakself.filteredChats = weakself.messageModels;

        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
    });
}

- (void) selectChatMessage:(ChatMessageModel *) chat {
    [_selectedModels addObject:chat];
    for (ChatMessageModel *model in _messageModels) {
        if (chat.messageData.messageId == model.messageData.messageId) {
            
            model.selected = TRUE;
            break;
        }
    }
    self.filteredChats = self.messageModels;
    __weak ChatDetailViewModel *weakself = self;
    dispatch_async( dispatch_get_main_queue(), ^{
        
        [weakself.delegate didUpdateObject:chat];
    });
}
- (void) deselectChatMessage:(ChatMessageModel *) chat {
    [_selectedModels removeObject:chat];
    for (ChatMessageModel *model in _messageModels) {
        if (chat.messageData.messageId == model.messageData.messageId) {
            
            model.selected = FALSE;
            break;
        }
    }
    __weak ChatDetailViewModel *weakself = self;
    self.filteredChats = self.messageModels;
    dispatch_async( dispatch_get_main_queue(), ^{
        
        [weakself.delegate didUpdateObject:chat];
    });
}

- (void)deleteSelected {
    dispatch_queue_t myQueue = dispatch_queue_create("storage.chatdetail.delete", DISPATCH_QUEUE_CONCURRENT);
    __weak ChatDetailViewModel* weakself = self;
    dispatch_async(myQueue, ^{
        for (ChatMessageModel* model in weakself.selectedModels) {
            [weakself.storageManager deleteChatMessage:model.messageData];
            //TODO: Thêm reference count cho File. Nếu còn reference thì không xoá file.
            
            [weakself.messageModels removeObject:model];
        }
        
        weakself.filteredChats = weakself.messageModels;
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.delegate didUpdateData];
        });
    });
    
}

- (void)addImage:(NSData *)data {
    __weak ChatDetailViewModel *weakself = self;
    NSString* chatRoomId = _chatRoom.chatRoomId;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_SERIAL);
    dispatch_async(myQueue, ^{
        
        NSString *checkSum = [HashHelper hashDataMD5:data];
        NSString *messageId = [[NSUUID UUID] UUIDString];
      
        double size = ((double)data.length/1024.0f)/1024.0f; // MB
    
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:chatRoomId];
        
        NSString *chatRoomName = weakself.chatRoom.chatRoomId;
        
        NSString *fileName = [NSString stringWithFormat:@"%@.png", newMessageData.messageId];
        NSString *componentFolderPath = [chatRoomName stringByAppendingPathComponent:fileName];
        NSString *filePath = [FileHelper documentsPathForFileName:componentFolderPath];
        
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
        fileData.tempData = data;
        fileData.type = Picture;
        
        [weakself.storageManager saveFileData:fileData];
        [weakself.storageManager saveChatMessageData:newMessageData];
        
        // Update UI Model
        UIImage *image = [UIImage imageWithData:data];
        ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:image];
        
        [weakself.messageModels insertObject:newModel atIndex:0];
        weakself.filteredChats = weakself.messageModels;

        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
    });
}

//- (void)compressThenCache: (UIImage*)image withKey:(NSString*) key {
//
//    __weak ChatDetailViewModel *weakself = self;
//    dispatch_queue_t myQueue = dispatch_queue_create("storage.cache.image", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(myQueue, ^{
//        [CompressorHelper compressImage:image quality:Thumbnail completionBlock:^(UIImage* compressedImage){
//
//            [weakself.storageManager cacheImageByKey:image withKey:key];
//        }];
//    });
//}

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [_storageManager cacheImageByKey:image withKey:key];
}
@end
