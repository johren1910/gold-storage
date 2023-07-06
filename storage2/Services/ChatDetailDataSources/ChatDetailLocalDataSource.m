//
//  ChatDetailLocalDataSource.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatDetailLocalDataSource.h"
#import "ChatMessageData.h"

@implementation ChatDetailLocalDataSource

- (void)getChatDataOfRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray<ChatMessageData *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [_storageManager getChatMessagesByRoomId:roomId completionBlock:^(id object){
        completionBlock(object);
        
    }];
}

- (void) getFileOfMessageId:(NSString*)messageId completionBlock:(void(^)(FileData* fileData))completionBlock {
    [_storageManager getFileOfMessageId:messageId completionBlock:^(id object){
        completionBlock(object);
    }];
}

- (void)updateFileData:(FileData*) fileData completionBlock:(void(^)(BOOL isFinish))completionBlock {
    [_storageManager updateFileData:fileData completionBlock:^(BOOL isFinish) {
        completionBlock(isFinish);
    }];
}

- (void)updateMessageData:(ChatMessageData*) message completionBlock:(void(^)(BOOL isFinish))completionBlock {
    [_storageManager updateMessageData:message completionBlock:^(BOOL isFinish) {
        completionBlock(isFinish);
    }];
}

- (void)deleteChatMessages:(NSArray<ChatMessageData*>*)messages completionBlock:(void(^)(BOOL isComplete))completionBlock {
    for (ChatMessageData* message in messages) {
        [_storageManager deleteChatMessage:message completionBlock:nil];
    }
    completionBlock(true);
    
}

- (void) saveImageWithData:(NSData*)data ofRoomId:(NSString*)roomId completionBlock:(void(^)(ChatMessageData* entity)) completionBlock {
    [_storageManager uploadImage:data withRoomId:roomId completionBlock:completionBlock];
}

- (void)getChatDataForMessageId:(NSString*)messageId completionBlock:(void (^)(ChatMessageData* chat))completionBlock {
    [_storageManager getMessageOfId:messageId completionBlock:completionBlock];
}

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [_storageManager cacheImageByKey:image withKey:key];
}

@end
