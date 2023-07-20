//
//  ChatRoomBusinessModel.m
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomBusinessModel.h"
#import "FileHelper.h"
#import "CacheService.h"

@interface ChatRoomBusinessModel ()
@property (nonatomic) dispatch_queue_t backgroundQueue;

@end

@implementation ChatRoomBusinessModel

-(instancetype) initWithRepository:(id<ChatRoomRepositoryInterface>)repository {
    if (self == [super init]) {
        self.chatRoomRepository = repository;
        self.backgroundQueue = dispatch_queue_create("com.chatroom.businessModel.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak ChatRoomBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatRoomRepository.chatRoomProvider createChatRoom:chatRoom completionBlock:completionBlock errorBlock:errorBlock];
    });
    
}

- (void)deleteChatRoom:(ChatRoomEntity*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak ChatRoomBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatRoomRepository.chatRoomProvider deleteChatRoom:chatRoom completionBlock:completionBlock errorBlock:errorBlock];
    });
}

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak ChatRoomBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatRoomRepository.chatRoomProvider getChatRoomsByPage:page completionBlock:completionBlock errorBlock:errorBlock];
    });
}

@end
