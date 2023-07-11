//
//  ChatRoomProvider.m
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import "ChatRoomProvider.h"
#import "ChatRoomEntity.h"

@interface ChatRoomProvider ()
@property (nonatomic) id<StorageManagerType> storageManager;
@end

@implementation ChatRoomProvider

-(instancetype)initWithStorageManager:(id<StorageManagerType>)storageManager {
    if (self ==[super init]) {
        self.storageManager = storageManager;
    }
    return self;
}

- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [_storageManager createChatRoom:chatRoom completionBlock:completionBlock];
    
}

- (void)deleteChatRoom:(ChatRoomEntity*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    ChatRoomData* roomData = [[ChatRoomData alloc] initWithName:chatRoom.name chatRoomId:chatRoom.roomId];
    [_storageManager deleteChatRoom:roomData completionBlock:completionBlock];
    
}

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomEntity *> *rooms))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    [_storageManager getChatRoomsByPage:page completionBlock:^(NSArray<ChatRoomData*>*rooms){
        NSMutableArray<ChatRoomEntity*>* results = [[NSMutableArray alloc] init];
        for (ChatRoomData* data in rooms) {
            ChatRoomEntity* entity = [data toChatRoomEntity];
            [results addObject:entity];
        }
        completionBlock([results copy]);
    }];
}

@end
