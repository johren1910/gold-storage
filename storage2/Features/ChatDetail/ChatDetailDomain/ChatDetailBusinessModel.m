//
//  ChatDetailBusinessModel.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatDetailBusinessModel.h"
#import "FileHelper.h"
#import "CacheService.h"
#import "FileData.h"

@interface ChatDetailBusinessModel ()
@property (nonatomic) dispatch_queue_t backgroundQueue;

@end

@implementation ChatDetailBusinessModel

-(instancetype) initWithRepository:(id<ChatDetailRepositoryInterface>)repository {
    if (self == [super init]) {
        self.chatDetailRepository = repository;
        self.backgroundQueue = dispatch_queue_create("com.chatdetail.businessModel.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)getChatDetailsOfRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray<ChatDetailEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak ChatDetailBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatDetailRepository.chatMessageProvider getChatMessagesByRoomId:roomId completionBlock:completionBlock errorBlock:errorBlock];
    });
}

- (void)saveImageWithData:(NSData *)data
                 ofRoomId:(NSString*)roomId completionBlock:(void (^)(ChatDetailEntity *))completionBlock errorBlock:(void (^)(NSError *))errorBlock {
    
    __weak ChatDetailBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatDetailRepository.fileDataProvider saveImageWithData:data ofRoomId:roomId completionBlock:^(ChatDetailEntity* entity){
            completionBlock(entity);
        } errorBlock:^(NSError* error) {
            
        }];
    });
}


- (void)requestDownloadFileWithUrl:(NSString *)url forRoom:(ChatRoomEntity*)roomData completionBlock:(void (^)(ChatDetailEntity *entity, BOOL isDownloaded))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
   
    dispatch_async(_backgroundQueue, ^{
        __weak ChatDetailBusinessModel* weakself = self;
        NSString *messageId = [[NSUUID UUID] UUIDString];
        NSString *fileId = [[NSUUID UUID] UUIDString];
        __block ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:roomData.roomId];
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
        
        [weakself.chatDetailRepository.chatMessageProvider saveMessage:newMessageData completionBlock:^(ChatDetailEntity* entity){
            
            FileDataWrapper *dataWrapper = [[FileDataWrapper alloc] init];
            dataWrapper.fileData = newFileData;
            dataWrapper.nsData = nil;
            [weakself.chatDetailRepository.fileDataProvider saveFileData:dataWrapper completionBlock:^(id object) {
                completionBlock(entity, false);
                // Start Request Download
                [weakself _startDownload:url forMessage:newMessageData
                                  ofRoom:roomData completionBlock: ^(ChatDetailEntity* entity) {
                    newMessageData = nil;
                    completionBlock(entity, true);
                }];
            }];
        }];
    });
    
}

- (void)resumeDownloadForEntity:(ChatDetailEntity *)entity OfRoom:(ChatRoomEntity*)roomData completionBlock:(void (^)(ChatDetailEntity *entity))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    __weak ChatDetailBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatDetailRepository.chatMessageProvider getChatMessageOfMessageId:entity.messageId completionBlock:^(ChatMessageData* message){
            dispatch_async(weakself.backgroundQueue, ^{
                [weakself _startDownload:entity.file.filePath forMessage:message ofRoom:roomData completionBlock:completionBlock];
            });
            
        } errorBlock:errorBlock];
    });
}

- (void)deleteChatEntities:(NSArray<ChatDetailEntity*>*)entities completionBlock:(void (^)(BOOL isSuccess))completionBlock {
    
    __weak ChatDetailBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatDetailRepository.chatMessageProvider deleteChatMessagesOf:entities completionBlock:completionBlock];
    });
    
}

#pragma mark: - Private methods

- (void)_startDownload:(NSString *)url forMessage:(ChatMessageData*)message
                ofRoom:(ChatRoomEntity*)model completionBlock:(void(^)(ChatDetailEntity* entity))completionBlock {
    
    __weak ChatDetailBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        ZODownloadItem* item = [[ZODownloadItem alloc] init];
        item.requestUrl = url;
        item.destinationDirectoryPath = nil;
        item.isBackgroundSession = false;
        item.priority = ZODownloadPriorityHigh;
        item.progressBlock = ^(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds) {
            NSLog(@"progress: %f\nspeed: %ld\nremainSeconds:%ld", progress,speed,remainingSeconds);
        };
        
        [weakself.chatDetailRepository startDownloadWithItem:item forMessage:message completionBlock:^(FileData* fileData, UIImage* thumbnail){
            
            message.file = fileData;
            message.messageState = Sent;
            ChatDetailEntity* result = [message toChatDetailEntity];
            result.thumbnail = thumbnail;
            completionBlock(result);
            message.file = nil;
        }];
    });
    
}

@end
