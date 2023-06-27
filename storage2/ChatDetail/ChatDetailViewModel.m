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
#import <MobileCoreServices/MobileCoreServices.h>

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
        NSArray<ChatMessageData*>* result = [weakself.databaseManager getChatMessagesByRoomId:weakself.chatRoom.chatRoomId];
        
        if (result != nil) {
            
            NSMutableArray<ChatMessageModel*>* modelResult = [@[] mutableCopy];
            
            for (ChatMessageData* messageData in result) {
                
                UIImage* cachedImage = [weakself.cacheService getImageByKey:messageData.messageId];
                
                ChatMessageModel* model = [[ChatMessageModel alloc] initWithMessageData:messageData thumbnail:cachedImage];
                
                [modelResult addObject:model];
                
                if (messageData.type == Download) {
                    [weakself requestDownloadWithUrl:messageData.filePath forMessageId:messageData.messageId];
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
    
    NSString *predicateString = @"messageData.type =[c] %ld";
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
        NSString *placeHolderId = [[NSUUID UUID] UUIDString];
        
        ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:placeHolderId messageId:placeHolderId chatRoomId:weakself.chatRoom.chatRoomId type:Download];
        ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:nil];
        
        [weakself.messageModels insertObject:newModel atIndex:0];
        weakself.filteredChats = weakself.messageModels;

        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
        
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
       
        newMessageData.filePath = url;
        newMessageData.createdAt = timeStamp;
        
        [weakself.databaseManager saveChatMessageData:newMessageData totalRoomSize:0];
        
        [weakself requestDownloadWithUrl:url forMessageId:placeHolderId];
    });
    
}

- (void)requestDownloadWithUrl:(NSString *)url forMessageId:(NSString*) messageId {
    
    ChatMessageModel *requestModel = nil;
    for (ChatMessageModel* model in self.messageModels) {
        if ([model.messageData.messageId isEqualToString:messageId]) {
            requestModel = model;
        }
        break;
    }
    
    NSString *chatRoomName = self.chatRoom.chatRoomId;
    NSString *folderPath = [FileHelper documentsPathForFileName:chatRoomName];

    __weak ChatDetailViewModel* weakself = self;

    [_downloadManager startDownloadWithUrl:url destinationDirectory:folderPath isBackgroundDownload: FALSE progressBlock:^(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds) {

        NSLog(@"progress: %f\nspeed: %ld\nremainSeconds:%ld", progress,speed,remainingSeconds);

    } completionBlock:^(NSString *destinationPath) {

        [weakself addDownloadedMedia:destinationPath withMessageId:messageId];
        NSLog(@"destinationPath download: %@", destinationPath);
    } errorBlock:^(NSError *error) {

    }];
}

- (void)addDownloadedMedia:(NSString *)filePath withMessageId:(NSString*)messageId {
    __weak ChatDetailViewModel *weakself = self;
    NSString* chatRoomId = _chatRoom.chatRoomId;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_SERIAL);
    dispatch_async(myQueue, ^{
        
        NSData *fileData = [FileHelper readFileAtPathAsData:filePath];

        ZOMediaInfo *mediaInfo = [FileHelper getMediaInfoOfFilePath:filePath];
        
        UIImage *thumbnail = mediaInfo.thumbnail;
        
        [weakself compressThenCache:thumbnail withKey:messageId];
        
        double size = ((double)fileData.length/1024.0f)/1024.0f; // MB
    
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:chatRoomId];
        
        CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
            newMessageData.type = Picture;
        }
        else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
            newMessageData.type = Video;
        }
        else if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
            NSLog(@"Text type");
        }
        CFRelease(fileUTI);
        
        newMessageData.size = size;
        newMessageData.filePath = filePath;
        newMessageData.createdAt = timeStamp;
        newMessageData.duration = mediaInfo.duration;
        
        [[weakself databaseManager] updateChatMessage:newMessageData];
     
        ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:thumbnail];
        
        __block NSUInteger index = 0;
        [weakself.messageModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ChatMessageModel *model = (ChatMessageModel *)obj;
            if ([model.messageData.messageId isEqualToString:messageId]) {
                index = idx;
                *stop = YES;
            }
            
        }];
        
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
    
    _filteredChats = self.messageModels;
    dispatch_async( dispatch_get_main_queue(), ^{
        [self.delegate didReloadData];
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
    
    _filteredChats = self.messageModels;
    dispatch_async( dispatch_get_main_queue(), ^{
        [self.delegate didReloadData];
    });
}

- (void)deleteSelected {
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_CONCURRENT);
    __weak ChatDetailViewModel* weakself = self;
    dispatch_async(myQueue, ^{
        for (ChatMessageModel* model in weakself.selectedModels) {
            [weakself.databaseManager deleteChatMessage:model.messageData];
            [weakself.cacheService deleteImageByKey:model.messageData.messageId];
            
            //TODO: Thêm reference count cho File. Nếu còn reference thì không xoá file.
            [FileHelper removeItemAtPath:model.messageData.filePath];
            
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
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        
        NSString *messageId = [HashHelper hashDataMD5:data];
        
        UIImage *image = [UIImage imageWithData:data];
        
        [weakself compressThenCache:image withKey:messageId];
        
        double size = ((double)data.length/1024.0f)/1024.0f; // MB
    
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:chatRoomId];
        
        NSString *chatRoomName = weakself.chatRoom.chatRoomId;
        
        NSString *fileName = [NSString stringWithFormat:@"%@.png", newMessageData.messageId];
        NSString *componentFolderPath = [chatRoomName stringByAppendingPathComponent:fileName];
        NSString *filePath = [FileHelper documentsPathForFileName:componentFolderPath];
        
        [FileHelper createDirectoriesForFileAtPath:filePath];
        
        //TODO: -Check storage space, not enough space?
        [data writeToFile:filePath atomically:YES];
        newMessageData.size = size;
        newMessageData.type = Picture;
        newMessageData.filePath = filePath;
        newMessageData.createdAt = timeStamp;
        
        [weakself.databaseManager saveChatMessageData:newMessageData totalRoomSize:weakself.chatRoom.size];
        ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:image];
        
        [weakself.messageModels insertObject:newModel atIndex:0];
        weakself.filteredChats = weakself.messageModels;

        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
    });
}

- (void)compressThenCache: (UIImage*)image withKey:(NSString*) key {
    
    __weak ChatDetailViewModel *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cache.image", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        [CompressorHelper compressImage:image quality:Thumbnail completionBlock:^(UIImage* compressedImage){
            
            [weakself.cacheService cacheImageByKey:image withKey:key];
        }];
    });
}

- (void)addFile:(NSData *)data {
    __weak ChatDetailViewModel *weakself = self;
    double size = ((double)data.length/1024.0f)/1024.0f; // MB
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *messageId = [NSString stringWithFormat:@"%.0f", timeStamp];
    
    ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:_chatRoom.chatRoomId];
    newMessageData.size = size;
//    new.type = File;
//    new.data = data;
    //TEMP IMAGE
    if (@available(iOS 13.0, *)) {
//        new.image = [UIImage systemImageNamed:@"doc"];
    } else {
        // Fallback on earlier versions
    }
    
    ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:nil];
    
    [weakself.messageModels insertObject:newModel atIndex:0];
    
    weakself.filteredChats = weakself.messageModels;

    dispatch_async( dispatch_get_main_queue(), ^{
        [weakself.delegate didUpdateData];
    });
}

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [_cacheService cacheImageByKey:image withKey:key];
}
@end
