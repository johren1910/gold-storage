//
//  ChatDetailRemoteDataSource.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//
#import "ChatDetailRemoteDataSource.h"

@implementation ChatDetailRemoteDataSource

- (void)getChatDataOfRoomId:(NSString*)roomId successCompletion:(void (^)(NSArray<ChatMessageData *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    successCompletion(@[]);
    
}

@end
