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
@property (nonatomic) BOOL isCheatOn;
@property (nonatomic) dispatch_queue_t backgroundQueue;
@end

@implementation ChatDetailViewModel

-(instancetype) initWithChatRoom: (ChatRoomModel*) chatRoom {
    self = [super init];
    if (self) {
        self.messageModels = [[NSMutableArray alloc] init];
        self.selectedModels = [[NSMutableArray alloc] init];
        self.backgroundQueue = dispatch_queue_create("com.chatdetai.viewmodel.backgroundqueue", DISPATCH_QUEUE_SERIAL);
        self.isCheatOn = FALSE;
    }
    _chatRoom = chatRoom;
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messageModels = [[NSMutableArray alloc] init];;
        if ([[UICollectionView class] instancesRespondToSelector:@selector(setPrefetchingEnabled:)]) {
            [[UICollectionView appearance] setPrefetchingEnabled:NO];
        }
    }
    
    return self;
}

- (void)getData:(void (^)(NSArray<ChatMessageModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    __weak ChatDetailViewModel *weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.storageManager getChatMessagesByRoomId:weakself.chatRoom.chatRoomId completionBlock:^(id object) {
            
            NSArray* result = (NSArray*)object;
            
            if (result != nil) {
                
                NSMutableArray<ChatMessageModel*>* modelResult = [@[] mutableCopy];
                
                for (ChatMessageData* messageData in result) {
                    
                    UIImage* cachedImage = [weakself.storageManager getImageByKey:messageData.file.checksum];
                    
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
        }];
    });
}

- (ChatMessageModel *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.filteredChats.count) {
        return nil;
    }
    
    return self.filteredChats[indexPath.row];
}

- (void)changeSegment: (NSInteger) index {
    if (index == 0) {
        _filteredChats = _messageModels;
        [self.delegate didUpdateData];
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
   
    [_delegate didUpdateData];
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSArray<ChatMessageModel*>*) items {
    return _filteredChats;
}

- (void)downloadFileWithUrl:(NSString *)url {
    if (_isCheatOn) {
        [self fakeDownload100Images:url];
        return;
    }
    
    NSString *messageId = [[NSUUID UUID] UUIDString];
    NSString *fileId = [[NSUUID UUID] UUIDString];

    ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:self.chatRoom.chatRoomId];

    FileData *newFileData = [[FileData alloc] init];
    newFileData.type = Download;
    newFileData.fileId = fileId;
    newFileData.messageId = messageId;

    newMessageData.file = newFileData;

    ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:nil];

    [self.messageModels insertObject:newModel atIndex:0];
    self.filteredChats = self.messageModels;

    [self.delegate didUpdateData];

    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];

    newFileData.filePath = url;
    newMessageData.createdAt = timeStamp;
    newFileData.createdAt = timeStamp;

    __weak ChatDetailViewModel* weakself = self;
    [self.storageManager createChatMessage:newMessageData completionBlock:^(BOOL isSuccess){
        [weakself.storageManager createFile:newFileData completionBlock:^(BOOL isSaved){
            [weakself requestDownloadWithUrl:url forFileId:fileId andMessageId:messageId];

        }];
    }];
}

- (void)requestDownloadWithUrl:(NSString *)url forFileId:(NSString*) fileId andMessageId:(NSString*)messageId {
    
    NSString *chatRoomName = self.chatRoom.chatRoomId;
    NSString *folderPath = [FileHelper pathForApplicationSupportDirectoryWithPath:chatRoomName];

    __weak ChatDetailViewModel* weakself = self;

    // TO RANDOM PRIORITY
                uint32_t rnd = arc4random_uniform(2);
    ZODownloadPriority priority = (rnd == 1) ? ZODownloadPriorityHigh : ZODownloadPriorityNormal;
    // DELETE AFTER TESTING ABOVE
    
    [_downloadManager startDownloadWithUrl:url destinationDirectory:folderPath isBackgroundDownload: FALSE priority: priority progressBlock:^(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds) {

        NSLog(@"progress: %f\nspeed: %ld\nremainSeconds:%ld", progress,speed,remainingSeconds);

    } completionBlock:^(NSString *destinationPath) {

        [weakself addDownloadedMedia:destinationPath withFileId:fileId andMessageId:messageId];
        NSLog(@"destinationPath download: %@", destinationPath);
    } errorBlock:^(NSError *error) {
        NSLog(@"error");
    }];
}

- (void)addDownloadedMedia:(NSString *)filePath withFileId:(NSString*)fileId andMessageId:(NSString*)messageId {
    __weak ChatDetailViewModel *weakself = self;
    dispatch_async(_backgroundQueue, ^{
        
        // Check if db still exist before processing.
        NSData *fileData = [FileHelper readFileAtPathAsData:filePath];
        NSString *checkSum = [HashHelper hashDataMD5:fileData];
        UIImage *thumbnail = [weakself.storageManager getImageByKey:checkSum];
        ZOMediaInfo *mediaInfo = [FileHelper getMediaInfoOfFilePath:filePath];
        if (!thumbnail) {
            
            thumbnail = mediaInfo.thumbnail;
            [weakself.storageManager compressThenCache:thumbnail withKey:checkSum];
        }
        
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
        
        [[weakself storageManager] updateFileData:newFileData completionBlock:^(BOOL isSuccess){
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
        }];
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
    
    [self.delegate didUpdateObject:chat];
}
- (void) deselectChatMessage:(ChatMessageModel *) chat {
    [_selectedModels removeObject:chat];
    for (ChatMessageModel *model in _messageModels) {
        if (chat.messageData.messageId == model.messageData.messageId) {
            
            model.selected = FALSE;
            break;
        }
    }
    self.filteredChats = self.messageModels;
    [self.delegate didUpdateObject:chat];
}

- (void)deleteSelected {
    for (ChatMessageModel* model in self.selectedModels) {
        
        __weak ChatDetailViewModel* weakself = self;
        [self.downloadManager cancelDownloadOfUrl:model.messageData.file.filePath];
        [self.storageManager deleteChatMessage:model.messageData completionBlock:^(BOOL isSuccess) {
            if(isSuccess) {
                [weakself.messageModels removeObject:model];
                weakself.filteredChats = weakself.messageModels;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.delegate didUpdateData];
                });
                
            }
        }];
    }
    
}

- (void)fakeUpload100Images:(NSData *)data {
    __weak ChatDetailViewModel* weakself = self;
    
    UIImage* fake1 = [UIImage imageNamed:@"circle-filled"];
    UIImage* fake2 = [UIImage imageNamed:@"circle-empty"];
    UIImage* fake3 = [UIImage imageNamed:@"video"];
    NSArray<NSData*>* fakeDatas = @[data, UIImagePNGRepresentation(fake1), UIImagePNGRepresentation(fake2),UIImagePNGRepresentation(fake3)];
    dispatch_async(_backgroundQueue, ^{
        for (int i=0; i<100; i++) {
//            uint32_t rnd = arc4random_uniform([fakeDatas count]);
//            NSData *chosenTest = [fakeDatas objectAtIndex:rnd];
            [weakself.storageManager uploadImage:data withRoomId:weakself.chatRoom.chatRoomId completionBlock:^(id object){
               
                ChatMessageData* messageData = (ChatMessageData*)object;
                
                UIImage *image = [weakself.storageManager getImageByKey:messageData.file.checksum];
                if (!image) {
                     image = [UIImage imageWithData:data];
                [weakself.storageManager cacheImageByKey:image withKey:messageData.file.checksum];
                }
               
                ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:messageData thumbnail:image];
                
                [weakself.messageModels insertObject:newModel atIndex:0];
                weakself.filteredChats = weakself.messageModels;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.delegate didUpdateData];
                });
                
            }];
        }
    });
    
}

- (void) fakeDownload100Images:(NSString*)url {
    __weak ChatDetailViewModel* weakself = self;
    
    NSString* link1 = @"https://getsamplefiles.com/download/mp4/sample-5.mp4";
    NSString* link2 = @"https://joy1.videvo.net/videvo_files/video/free/2016-05/large_watermarked/Mykonos_2_preview.mp4";
    NSString* link3 = @"https://joy1.videvo.net/videvo_files/video/free/2016-08/large_watermarked/VID_20160517_175443_preview.mp4";
    NSString* link4 = @"https://freetestdata.com/wp-content/uploads/2022/02/Free_Test_Data_7MB_MP4.mp4";
    NSString* link5 = @"https://joy1.videvo.net/videvo_files/video/free/2013-11/large_watermarked/SUPER8MMSTOCKEMULTIONNicholasLever_preview.mp4";
    NSString* link6 = @"https://joy1.videvo.net/videvo_files/video/free/2015-08/large_watermarked/Dream_lake_1_preview.mp4";
    NSString* link7 = @"https://joy1.videvo.net/videvo_files/video/free/2015-08/large_watermarked/Surfer1_preview.mp4";
    NSString* link8 = @"https://freetestdata.com/wp-content/uploads/2022/02/Free_Test_Data_5.05MB_MOV.mov";
    NSString* link9 = @"https://freetestdata.com/wp-content/uploads/2022/02/Free_Test_Data_2MB_MP4.mp4";
    NSString* link10 = @"https://freetestdata.com/wp-content/uploads/2021/10/Free_Test_Data_1MB_MOV.mov";

    NSArray<NSString*>* rand = @[link1, link2,link3,link4,link5,link6,link7,link8,link9,link10];
    dispatch_async(_backgroundQueue, ^{
        for (int i=0; i<100; i++) {
            uint32_t rnd = arc4random_uniform(rand.count);
            NSString *chosenTest = [rand objectAtIndex:rnd];
            
            NSString *url = url;
            url = chosenTest;
            NSString *messageId = [[NSUUID UUID] UUIDString];
            NSString *fileId = [[NSUUID UUID] UUIDString];
            
            ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:weakself.chatRoom.chatRoomId];
            
            FileData *newFileData = [[FileData alloc] init];
            newFileData.type = Download;
            newFileData.fileId = fileId;
            newFileData.messageId = messageId;
            
            newMessageData.file = newFileData;
            
            ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:nil];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.messageModels insertObject:newModel atIndex:0];
                weakself.filteredChats = weakself.messageModels;

                [weakself.delegate didUpdateData];
            });
            
            
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
           
            newFileData.filePath = url;
            newMessageData.createdAt = timeStamp;
            newFileData.createdAt = timeStamp;
            
            [weakself.storageManager createChatMessage:newMessageData completionBlock:^(BOOL isSuccess){
                [weakself.storageManager createFile:newFileData completionBlock:^(BOOL isSaved){
                    [weakself requestDownloadWithUrl:url forFileId:fileId andMessageId:messageId];
                    
                }];
            }];
        }
    });
}

- (void)setCheat:(BOOL)isOn {
    _isCheatOn = isOn;
}

- (void)addImage:(NSData *)data {
    if (self.isCheatOn) {
        [self fakeUpload100Images:data];
        return;
    }
    
    __weak ChatDetailViewModel *weakself = self;
    [_storageManager uploadImage:data withRoomId:_chatRoom.chatRoomId completionBlock:^(id object){
        ChatMessageData* messageData = (ChatMessageData*)object;
        UIImage *image = [UIImage imageWithData:data];
        ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:messageData thumbnail:image];

        [weakself.messageModels insertObject:newModel atIndex:0];
        weakself.filteredChats = weakself.messageModels;

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
    }];
}

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [_storageManager cacheImageByKey:image withKey:key];
}
@end
