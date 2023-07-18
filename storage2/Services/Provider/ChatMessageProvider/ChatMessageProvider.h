//
//  ChatMessageProvider.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import <Foundation/Foundation.h>
#import "StorageManagerType.h"

@protocol ChatMessageProviderType

-(instancetype)initWithStorageManager:(id<StorageManagerType>)storageManager;
-(void)getChatMessagesByRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray* objects))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
-(void)getChatMessageOfMessageId:(NSString*)messageId completionBlock:(void (^)(id object))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)deleteChatMessagesOf:(NSArray*)messages completionBlock:(void(^)(BOOL isFinish))completionBlock;
- (void)updateMessage:(ChatMessageData*)message completionBlock:(void(^)(BOOL isFinish))completionBlock;
- (void)saveMessage:(ChatMessageData*)message completionBlock:(void(^)(id entity))completionBlock;
@end

@interface ChatMessageProvider : NSObject <ChatMessageProviderType>

@end
