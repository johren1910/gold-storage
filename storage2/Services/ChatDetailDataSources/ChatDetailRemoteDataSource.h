//
//  ChatDetailRemoteDataSourceInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatMessageData.h"

@protocol ChatDetailRemoteDataSourceType

- (void)getChatDataOfRoomId:(NSString*)roomId successCompletion:(void (^)(NSArray<ChatMessageData *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;
@end

@interface ChatDetailRemoteDataSource : NSObject <ChatDetailRemoteDataSourceType>
-(instancetype)init:(NSString*) baseUrl;
@end
