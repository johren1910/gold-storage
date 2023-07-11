//
//  ChatRoomRepositoryInterface.h
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomEntity.h"
#import "ChatRoomData.h"
#import "ChatRoomProvider.h"

@protocol ChatRoomRepositoryInterface

@property (nonatomic) id<ChatRoomProviderType> chatRoomProvider;
@end
