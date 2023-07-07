//
//  ChatRoomDataRepository.h
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomRepositoryInterface.h"
#import "ChatRoomLocalDataSource.h"
#import "ChatRoomRemoteDataSource.h"
#import "StorageManager.h"

@interface ChatRoomDataRepository : NSObject <ChatRoomRepositoryInterface>
-(instancetype) initWithRemote:(id<ChatRoomRemoteDataSourceType>)remoteDataSource andLocal:(id<ChatRoomLocalDataSourceType>)localDataSource andStorageManager:(id<StorageManagerType>)storageManager;

@end

