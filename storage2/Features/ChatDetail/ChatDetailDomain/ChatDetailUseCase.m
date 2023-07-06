//
//  ChatDetailUseCase.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatDetailUseCase.h"
#import "FileHelper.h"
#import "CacheService.h"

@interface ChatDetailUseCase ()
@property (nonatomic) dispatch_queue_t backgroundQueue;

@end

@implementation ChatDetailUseCase

-(instancetype) initWithRepository:(id<ChatDetailRepositoryInterface>)repository {
    if (self == [super init]) {
        self.chatDetailRepository = repository;
        self.backgroundQueue = dispatch_queue_create("com.chatdetail.usecase.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)getChatDetailsOfRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray<ChatDetailEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    __weak ChatDetailUseCase* weakself = self;
    [weakself.chatDetailRepository getChatDataOfRoomId: roomId completionBlock:completionBlock errorBlock:errorBlock];
}

- (void)saveImageWithData:(NSData *)data
                 ofRoomId:(NSString*)roomId completionBlock:(void (^)(ChatDetailEntity *))completionBlock errorBlock:(void (^)(NSError *))errorBlock {
    
    __weak ChatDetailUseCase* weakself = self;
    [weakself.chatDetailRepository saveImageWithData:data ofRoomId:roomId completionBlock:^(ChatDetailEntity* entity){
        completionBlock(entity);
    } errorBlock:^(NSError* error) {
        
    }];
}


- (void)requestDownloadFileWithUrl:(NSString *)url forRoom:(ChatRoomModel*)roomModel completionBlock:(void (^)(ChatDetailEntity *entity, BOOL isDownloaded))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    dispatch_async(_backgroundQueue, ^{
        __weak ChatDetailUseCase* weakself = self;
        NSString *messageId = [[NSUUID UUID] UUIDString];
        NSString *fileId = [[NSUUID UUID] UUIDString];

        ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:roomModel.chatRoomId];
        newMessageData.messageState = Downloading;

        FileData *newFileData = [[FileData alloc] init];
        newFileData.fileId = fileId;
        newFileData.messageId = messageId;

        newMessageData.file = newFileData;

        ChatDetailEntity *newModel = [[ChatDetailEntity alloc] init];
        newModel.messageId = newMessageData.messageId;
        newModel.file = newMessageData.file;

        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];

        newFileData.filePath = url;
        newMessageData.createdAt = timeStamp;
        newFileData.createdAt = timeStamp;
        
        [weakself.chatDetailRepository saveChatMessage:newMessageData completionBlock:^(ChatDetailEntity* entity){
            
            [weakself.chatDetailRepository saveFile:newFileData withNSData: nil completionBlock:^(BOOL isSuccess) {
                completionBlock(entity, false);
                // Start Request Download
                [weakself _startDownload:url forMessage:newMessageData
                                  ofRoom:roomModel completionBlock: ^(ChatDetailEntity* entity) {
                    
                    completionBlock(entity, true);
                }];
            }];
        }];
    });
    
}

- (void)resumeDownloadForEntity:(ChatDetailEntity *)entity OfRoom:(ChatRoomModel*)roomModel completionBlock:(void (^)(ChatDetailEntity *entity))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    __weak ChatDetailUseCase* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatDetailRepository getChatDataForMessageId:entity.messageId completionBlock:^(ChatMessageData* message){
            dispatch_async(weakself.backgroundQueue, ^{
                [weakself _startDownload:entity.file.filePath forMessage:message ofRoom:roomModel completionBlock:completionBlock];
            });
            
        } errorBlock:errorBlock];
    });
}

- (void)deleteChatEntities:(NSArray<ChatDetailEntity*>*)entities completionBlock:(void (^)(BOOL isSuccess))completionBlock {
    [_chatDetailRepository deleteChatMessages:entities completionBlock:completionBlock];
}

- (void)updateRamCache:(UIImage*)image withKey:(NSString*)key {
    [_chatDetailRepository updateRamCache:image withKey:key];
}

#pragma mark: - Private methods

- (void)_saveDownloadedMedia:(NSString *)filePath forMessage:(ChatMessageData*)message
    completionBlock:(void(^)(ChatDetailEntity* entity))completionBlock {
    
    [_chatDetailRepository saveMedia:filePath forMessage:message completionBlock:^(FileData* fileData, UIImage* thumbnail){
        
        message.file = fileData;
        message.messageState = Sent;
        ChatDetailEntity* result = [message toChatDetailEntity];
        result.thumbnail = thumbnail;
        completionBlock(result);
        
    }];
}

- (void)_startDownload:(NSString *)url forMessage:(ChatMessageData*)message
                ofRoom:(ChatRoomModel*)model completionBlock:(void(^)(ChatDetailEntity* entity))completionBlock {

    __weak ChatDetailUseCase* weakself = self;
    
    ZODownloadUnit* unit = [[ZODownloadUnit alloc] init];
    unit.requestUrl = url;
    unit.destinationDirectoryPath = nil;
    unit.isBackgroundSession = false;
    unit.priority = ZODownloadPriorityHigh;
    unit.progressBlock = ^(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds) {
        NSLog(@"progress: %f\nspeed: %ld\nremainSeconds:%ld", progress,speed,remainingSeconds);
    };
    
    [_chatDetailRepository startDownloadWithUnit:unit forMessage:message completionBlock:^(FileData* fileData, UIImage* thumbnail){
        
        message.file = fileData;
        message.messageState = Sent;
        ChatDetailEntity* result = [message toChatDetailEntity];
        result.thumbnail = thumbnail;
        completionBlock(result);
        
    }];
}

@end
