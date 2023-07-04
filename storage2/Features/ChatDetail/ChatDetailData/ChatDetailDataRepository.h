//
//  ChatDetailDataRepository.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatDetailReporitoryInterface.h"
#import "ChatDetailLocalDataSource.h"
#import "ChatDetailRemoteDataSource.h"
#import "StorageManager.h"

@interface ChatDetailDataRepository : NSObject <ChatDetailRepositoryInterface>
-(instancetype) initWithRemote:(id<ChatDetailRemoteDataSourceType>)remoteDataSource andLocal:(id<ChatDetailLocalDataSourceType>)localDataSource andStorageManager:(id<StorageManagerType>)storageManager;

@end
