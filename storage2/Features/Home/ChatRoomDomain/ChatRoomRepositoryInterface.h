//
//  ChatRoomRepositoryInterface.h
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomEntity.h"
#import "ChatRoomData.h"

@protocol ChatRoomRepositoryInterface

- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)deleteChatRoom:(ChatRoomEntity*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomEntity *> *rooms))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
@end
