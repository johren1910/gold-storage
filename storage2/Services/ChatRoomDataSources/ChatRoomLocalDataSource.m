//
//  ChatRoomLocalDataSource.m
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomLocalDataSource.h"
#import "ChatRoomData.h"

@implementation ChatRoomLocalDataSource

- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [_storageManager createChatRoom:chatRoom completionBlock:completionBlock];
}

- (void)deleteChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [_storageManager deleteChatRoom:chatRoom completionBlock:completionBlock];
}

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomData *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [_storageManager getChatRoomsByPage:page completionBlock:completionBlock];
    
}

@end
