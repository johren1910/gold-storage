//
//  ChatRoomDataRepository.m
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomDataRepository.h"
#import <UIKit/UIKit.h>
#import "ChatRoomProvider.h"

@interface ChatRoomDataRepository ()
@end

@implementation ChatRoomDataRepository

-(instancetype) initWithStorageManager:(id<StorageManagerType>)storageManager andChatRoomProvider:(id<ChatRoomProviderType>)chatRoomProvider {
    if (self == [super init]) {
        self.chatRoomProvider = chatRoomProvider;
    }
    return self;
}

@synthesize chatRoomProvider;

@end

