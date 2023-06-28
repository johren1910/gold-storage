//
//  StorageManager.h
//  storage2
//
//  Created by LAP14885 on 27/06/2023.
//

#import "StorageManagerType.h"

@interface StorageManager : NSObject <StorageManagerType>

-(instancetype) initWithCacheService:(id<CacheServiceType>)cacheService andDatabaseManager:(id<DatabaseManagerType>)databaseManager;

@property (strong,nonatomic) id<CacheServiceType> cacheService;
@property (strong,nonatomic) id<DatabaseManagerType> databaseManager;

# pragma mark - DB Operation
- (BOOL) saveChatRoomData:(ChatRoomModel*)chatRoom;
-(NSArray<ChatRoomModel*>*) getChatRoomsByPage:(int)page;
- (BOOL)saveChatMessageData:(ChatMessageData*) chatMessage;
- (BOOL)deleteChatMessage:(ChatMessageData*) message;
- (NSArray<ChatMessageData*>*) getChatMessagesByRoomId:(NSString*)chatRoomId;
- (BOOL)updateChatMessage:(ChatMessageData*) chatMessage;
- (BOOL)deleteChatRoom:(ChatRoomModel*) chatRoom;

# pragma mark - Cache Operation
-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key;
-(UIImage*)getImageByKey:(NSString*)key;
-(void)deleteImageByKey:(NSString*)key;

@end
