//
//  ChatRoomUseCase.m
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomUseCase.h"
#import "FileHelper.h"
#import "CacheService.h"

@interface ChatRoomUseCase ()
@property (nonatomic) dispatch_queue_t backgroundQueue;

@end

@implementation ChatRoomUseCase

-(instancetype) initWithRepository:(id<ChatRoomRepositoryInterface>)repository {
    if (self == [super init]) {
        self.chatRoomRepository = repository;
        self.backgroundQueue = dispatch_queue_create("com.chatroom.usecase.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak ChatRoomUseCase* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatRoomRepository createChatRoom:chatRoom completionBlock:^(BOOL isSuccess){
            completionBlock(isSuccess);
        } errorBlock:errorBlock];
    });
    
}

- (void)deleteChatRoom:(ChatRoomEntity*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak ChatRoomUseCase* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatRoomRepository deleteChatRoom:chatRoom completionBlock:completionBlock errorBlock:errorBlock];
    });
}

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak ChatRoomUseCase* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatRoomRepository getChatRoomsByPage:page completionBlock:completionBlock errorBlock:errorBlock];
    });
}

@end
