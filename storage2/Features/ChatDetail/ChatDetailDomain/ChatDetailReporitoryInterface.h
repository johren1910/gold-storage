//
//  ChatDetailReporitoryInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//
#import "ChatDetailEntity.h"

@protocol ChatDetailRepositoryInterface

- (void)getChatDataOfRoomId:(NSString*)roomId successCompletion:(void (^)(NSArray<ChatDetailEntity *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;

@end
