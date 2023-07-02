//
//  ChatDetailUseCase.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatDetailUseCase.h"

@implementation ChatDetailUseCase

-(instancetype) initWithRepository:(id<ChatDetailRepositoryInterface>)repository {
    if (self == [super init]) {
        self.chatDetailRepository = repository;
    }
    return self;
}

- (void)getChatDetailsOfRoomId:(NSString*)roomId successCompletion:(void (^)(NSArray<ChatDetailEntity *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion; {
    [_chatDetailRepository getChatDataOfRoomId: roomId successCompletion:successCompletion error:errorCompletion];
}

- (void)addImageWithData:(NSData *)data {
    
}

@end
