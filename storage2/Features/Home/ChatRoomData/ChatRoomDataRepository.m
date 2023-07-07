//
//  ChatRoomDataRepository.m
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomDataRepository.h"
#import <UIKit/UIKit.h>

@interface ChatRoomDataRepository ()
@property (nonatomic) id<ChatRoomLocalDataSourceType> localDataSource;
@property (nonatomic) id<ChatRoomRemoteDataSourceType> remoteDataSource;
@property (nonatomic) id<StorageManagerType> storageManager;
@property (nonatomic) dispatch_queue_t backgroundQueue;
@end

@implementation ChatRoomDataRepository

- (void)createChatRoom:(ChatRoomData*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [_localDataSource createChatRoom:chatRoom completionBlock:completionBlock errorBlock:errorBlock];
    
}

- (void)deleteChatRoom:(ChatRoomEntity*)chatRoom completionBlock:(void (^)(BOOL isSuccess))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    ChatRoomData* roomData = [[ChatRoomData alloc] initWithName:chatRoom.name chatRoomId:chatRoom.roomId];
    [_localDataSource deleteChatRoom:roomData completionBlock:completionBlock errorBlock:errorBlock];
    
}

- (void)getChatRoomsByPage:(int)page completionBlock:(void (^)(NSArray<ChatRoomEntity *> *rooms))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    [_localDataSource getChatRoomsByPage:page completionBlock:^(NSArray<ChatRoomData*>*rooms){
        NSMutableArray<ChatRoomEntity*>* results = [[NSMutableArray alloc] init];
        for (ChatRoomData* data in rooms) {
            ChatRoomEntity* entity = [data toChatRoomEntity];
            [results addObject:entity];
        }
        completionBlock([results copy]);
    } errorBlock:errorBlock];
    
}

-(instancetype) initWithRemote:(id<ChatRoomRemoteDataSourceType>)remoteDataSource andLocal:(id<ChatRoomLocalDataSourceType>)localDataSource andStorageManager:(id<StorageManagerType>)storageManager {
    if (self == [super init]) {
        self.localDataSource = localDataSource;
        self.remoteDataSource = remoteDataSource;
        self.storageManager = storageManager;
        self.backgroundQueue = dispatch_queue_create("com.chatroom.datarepository.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

@end

