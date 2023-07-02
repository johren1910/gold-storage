//
//  ChatDetailLocalDatasourceInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatMessageData.h"
#import "StorageManager.h"

@protocol ChatDetailLocalDataSourceType
- (void)getChatDataOfRoomId:(NSString*)roomId successCompletion:(void (^)(NSArray<ChatMessageData *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;
@end

@interface ChatDetailLocalDataSource : NSObject <ChatDetailLocalDataSourceType>

@property (nonatomic) id<StorageManagerType> storageManager;

@end
