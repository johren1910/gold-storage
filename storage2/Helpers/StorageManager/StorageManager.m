//
//  StorageManager.m
//  storage2
//
//  Created by LAP14885 on 27/06/2023.
//

#import <Foundation/Foundation.h>
#import "StorageManager.h"
#import "ChatMessageData.h"

@interface StorageManager ()
@property (nonatomic, strong) dispatch_queue_t storageQueue;
@end

@implementation StorageManager

-(instancetype) initWithCacheService:(id<CacheServiceType>)cacheService andDatabaseManager:(id<DatabaseManagerType>)databaseManager {
    
    if (self == [super init]) {
        self.storageQueue = dispatch_queue_create("com.storagemanager.queue", DISPATCH_QUEUE_SERIAL);
        self.cacheService = cacheService;
        self.databaseManager = databaseManager;
    }
    return self;
}

#pragma mark - DB Operation

- (BOOL) saveChatRoomData:(ChatRoomModel*)chatRoom {
    return [_databaseManager saveChatRoomData:chatRoom];
}

- (BOOL)saveChatMessageData:(ChatMessageData*) chatMessage {
    return [_databaseManager saveChatMessageData:chatMessage];
}

-(NSArray<ChatRoomModel*>*) getChatRoomsByPage:(int)page {
    return [_databaseManager getChatRoomsByPage:page];
}

// 1 - Delete from DB
// 2 - Delete from cache
// 3 - Delete from local
- (BOOL)deleteChatMessage:(ChatMessageData*) message {
   BOOL dbDeleted = [_databaseManager deleteChatMessage:message];
    [_cacheService deleteImageByKey:message.messageId];
    [FileHelper removeItemAtPath:message.filePath];
    return dbDeleted;
}

- (NSArray<ChatMessageData*>*) getChatMessagesByRoomId:(NSString*)chatRoomId {
    NSArray<ChatMessageData*>* result = [_databaseManager getChatMessagesByRoomId:chatRoomId];
    return result;
}

- (BOOL)updateChatMessage:(ChatMessageData*) chatMessage {
   return [_databaseManager updateChatMessage:chatMessage];
}
- (BOOL)deleteChatRoom:(ChatRoomModel*) chatRoom {
   return [_databaseManager deleteChatRoom:chatRoom];
}

# pragma mark - Cache Operation
-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key {
    [_cacheService cacheImageByKey:image withKey:key];
}
-(UIImage*)getImageByKey:(NSString*)key {
    return [_cacheService getImageByKey:key];
}
-(void)deleteImageByKey:(NSString*)key {
    [_cacheService deleteImageByKey:key];
}

@end
