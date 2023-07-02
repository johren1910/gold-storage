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
@property (nonatomic) id<ChatDetailLocalDataSourceType> localDataSource;
@property (nonatomic) id<ChatDetailRemoteDataSourceType> remoteDataSource;
@property (nonatomic) id<StorageManagerType> storageManager;

@end
