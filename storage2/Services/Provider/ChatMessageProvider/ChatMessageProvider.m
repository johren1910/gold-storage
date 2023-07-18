//
//  ChatMessageProvider.m
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import "ChatMessageProvider.h"
#import "ChatDetailEntity.h"

@interface ChatMessageProvider ()
@property (nonatomic) id<StorageManagerType> storageManager;
@end

@implementation ChatMessageProvider

-(instancetype)initWithStorageManager:(id<StorageManagerType>)storageManager {
    if (self ==[super init]) {
        self.storageManager = storageManager;
    }
    return self;
}

-(void)getChatMessagesByRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray* objects))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak ChatMessageProvider* weakself = self;
    [_storageManager getChatMessagesByRoomId:roomId completionBlock:^(NSArray<ChatMessageData*>* chats) {
        NSMutableArray<ChatDetailEntity*>* results = [[NSMutableArray alloc] init];
        for (ChatMessageData* data in chats) {
            ChatDetailEntity* entity = [data toChatDetailEntity];
            
            UIImage* thumbnail = [weakself.storageManager getImageByKey:entity.file.checksum];
            if (!thumbnail && entity.file.filePath != nil) {

                if (entity.file.type == Video) {
                    ZOMediaInfo *mediaInfo = [FileHelper getMediaInfoOfFilePath:entity.file.getAbsoluteFilePath];
                    thumbnail = mediaInfo.thumbnail;
                    [weakself.storageManager compressThenCache:thumbnail withKey:entity.file.checksum];
                } else {
                    NSData *imageData = [NSData dataWithContentsOfFile:entity .file.getAbsoluteFilePath];
                    thumbnail = [UIImage imageWithData:imageData];
                }

            }
            entity.thumbnail = thumbnail;
            [results addObject:entity];
        }
        
        completionBlock([results copy]);
    }];
}
-(void)getChatMessageOfMessageId:(NSString*)messageId completionBlock:(void (^)(id object))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [_storageManager getMessageOfId:messageId completionBlock:^(id object){
        completionBlock((ChatMessageData*)object);
    }];
}
- (void)deleteChatMessagesOf:(NSArray*)messages completionBlock:(void(^)(BOOL isFinish))completionBlock {
    
    __block int completionCount = 0;
    NSUInteger totalMessages = messages.count;
    for (ChatDetailEntity* entity in messages) {
        ChatMessageData* messageData = [[ChatMessageData alloc] initWithMessage:entity.messageId messageId:entity.messageId chatRoomId:nil];
        messageData.file = entity.file;
        
        [_storageManager deleteChatMessage:messageData completionBlock:^(BOOL isDelete) {
            completionCount++;
            if(completionCount >= totalMessages) {
                completionBlock(true);
            }
        }];
    }
}
- (void)updateMessage:(ChatMessageData*)message completionBlock:(void(^)(BOOL isFinish))completionBlock {
    [_storageManager updateMessageData:message completionBlock:completionBlock];
}
- (void)saveMessage:(ChatMessageData*)message completionBlock:(void(^)(id entity))completionBlock {
    [_storageManager createChatMessage:message completionBlock:^(BOOL isSuccess) {
        completionBlock([message toChatDetailEntity]);
    }];
}
@end
