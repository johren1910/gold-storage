//
//  ChatDetailDI.m
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatDetailBuilder.h"
#import "AppEnvironment.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "DatabaseService.h"
#import "ZODownloadManagerType.h"

@interface ChatDetailBuilder ()
@property (nonatomic) AppEnvironment* environment;
@end

@implementation ChatDetailBuilder

-(instancetype) init:(AppEnvironment*)environment {
    if (self == [super init]) {
        self.environment = environment;
    }
    return self;
}

-(id<ChatDetailRemoteDataSourceType>) getChatDetailRemoteDataSource {
    ChatDetailRemoteDataSource* remoteDataSource = [[ChatDetailRemoteDataSource alloc] init: _environment.baseUrl];
    remoteDataSource.downloadManager = _environment.downloadManager;
    return remoteDataSource;
}
-(id<ChatDetailLocalDataSourceType>) getChatDetailLocalDataSource {
    ChatDetailLocalDataSource *localDataSource = [[ChatDetailLocalDataSource alloc] init];
    localDataSource.storageManager = _environment.storageManager;
    return localDataSource;
}
-(id<StorageManagerType>) getStorageManager {
    return _environment.storageManager;
}
-(id<ChatDetailRepositoryInterface>) getChatDetailDataRepository {
    ChatDetailDataRepository* repository = [[ChatDetailDataRepository alloc] initWithRemote:[self getChatDetailRemoteDataSource] andLocal:[self getChatDetailLocalDataSource] andStorageManager:[self getStorageManager]];
    return repository;
}
-(id<ChatDetailBusinessModelInterface>) getChatDetailBusinessModel {
    ChatDetailBusinessModel* chatDetailBusinessModel = [[ChatDetailBusinessModel alloc] initWithRepository:[self getChatDetailDataRepository]];
    return chatDetailBusinessModel;
    
}
-(id<ChatDetailViewModelType>) getChatDetailViewModel:(id<ChatRoomEntityType>)roomEntity {
    ChatDetailViewModel *chatDetailViewModel = [[ChatDetailViewModel alloc] initWithChatRoom:roomEntity andBusinessModel:[self getChatDetailBusinessModel]];
    return chatDetailViewModel;
}
-(id<ViewControllerType>) getChatDetailViewController:(id<ChatRoomEntityType>)roomEntity {
    ChatDetailViewController *viewController = [[ChatDetailViewController alloc] initWithViewModel:[self getChatDetailViewModel:roomEntity]];
    viewController.title = roomEntity.name;
    return viewController;
}

@end
