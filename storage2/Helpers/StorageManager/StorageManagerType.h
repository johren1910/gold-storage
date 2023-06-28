//
//  StorageManagerType.h
//  storage2
//
//  Created by LAP14885 on 28/06/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CacheService.h"
#import "HashHelper.h"
#import "DatabaseManager.h"
#import "FileHelper.h"
#import "ChatRoomModel.h"
#import "FileData.h"

@protocol StorageManagerType <FactoryResolvable>

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
