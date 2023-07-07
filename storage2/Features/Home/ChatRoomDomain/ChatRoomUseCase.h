//
//  ChatRoomUseCase.h
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomRepositoryInterface.h"
#import "ChatRoomEntity.h"
#import "ChatRoomData.h"

@protocol ChatRoomUseCaseInterface

- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)deleteChatRoom:(ChatRoomEntity*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

@end

@interface ChatRoomUseCase : NSObject<ChatRoomUseCaseInterface>
@property (nonatomic) id<ChatRoomRepositoryInterface> chatRoomRepository;
-(instancetype) initWithRepository:(id<ChatRoomRepositoryInterface>)repository;

@end

