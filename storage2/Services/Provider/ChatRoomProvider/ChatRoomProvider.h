//
//  ChatRoomProvider.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import <Foundation/Foundation.h>
#import "StorageManagerType.h"

@protocol ChatRoomProviderType
-(instancetype)initWithStorageManager:(id<StorageManagerType>)storageManager;
- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)deleteChatRoom:(ChatRoomEntity*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomEntity *> *rooms))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

@end

@interface ChatRoomProvider : NSObject <ChatRoomProviderType>
@end

