//
//  ChatDetailLocalDataSource.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatDetailLocalDataSource.h"
#import "ChatMessageData.h"

@implementation ChatDetailLocalDataSource

- (void)getChatDataOfRoomId:(NSString*)roomId successCompletion:(void (^)(NSArray<ChatMessageData *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    [_storageManager getChatMessagesByRoomId:roomId completionBlock:^(id object){
        successCompletion(object);
        
    }];
}

@end
