//
//  ChatRoomLocalDataSource.h
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomData.h"
#import "StorageManager.h"

@protocol ChatRoomLocalDataSourceType
- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)deleteChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomData *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

@end

@interface ChatRoomLocalDataSource : NSObject <ChatRoomLocalDataSourceType>

@property (nonatomic) id<StorageManagerType> storageManager;

@end

