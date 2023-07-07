//
//  ChatRoomRemoteDataSource.h
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomData.h"

@protocol ChatRoomRemoteDataSourceType

@end

@interface ChatRoomRemoteDataSource : NSObject <ChatRoomRemoteDataSourceType>
-(instancetype)init:(NSString*) baseUrl;
@end

