//
//  ChatRoomDataRepository.h
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomRepositoryInterface.h"
#import "StorageManager.h"

@interface ChatRoomDataRepository : NSObject <ChatRoomRepositoryInterface>
-(instancetype) initWithStorageManager:(id<StorageManagerType>)storageManager andChatRoomProvider:(id<ChatRoomProviderType>)chatRoomProvider;

@end

