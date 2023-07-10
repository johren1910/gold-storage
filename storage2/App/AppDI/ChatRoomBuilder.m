//
//  ChatRoomDI.m
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomBuilder.h"

@interface ChatRoomBuilder ()
@property (nonatomic) AppEnvironment* environment;
@end

@implementation ChatRoomBuilder

-(instancetype) init:(AppEnvironment*)environment {
    if (self == [super init]) {
        self.environment = environment;
    }
    return self;
}

#pragma mark - Data layer
-(id<ChatRoomRemoteDataSourceType>) getChatRoomRemoteDataSource {
    NSString *baseUrl = _environment.baseUrl;
    ChatRoomRemoteDataSource* remoteDataSource = [[ChatRoomRemoteDataSource alloc] init:baseUrl];
    return remoteDataSource;
}
-(id<ChatRoomLocalDataSourceType>) getChatRoomLocalDataSource {
    ChatRoomLocalDataSource *localDataSource = [[ChatRoomLocalDataSource alloc] init];
    localDataSource.storageManager = _environment.storageManager;
    return localDataSource;
}
-(id<StorageManagerType>) getStorageManager {
    return _environment.storageManager;
}
-(id<ChatRoomRepositoryInterface>) getChatRoomDataRepository {
    ChatRoomDataRepository* repository = [[ChatRoomDataRepository alloc] initWithRemote:[self getChatRoomRemoteDataSource] andLocal:[self getChatRoomLocalDataSource] andStorageManager:[self getStorageManager]];
    return repository;
}

#pragma mark - Domain layer
-(id<ChatRoomBusinessModelInterface>) getChatRoomBusinessModel {
    ChatRoomBusinessModel* chatRoomBusinessModel = [[ChatRoomBusinessModel alloc] initWithRepository:[self getChatRoomDataRepository]];
    return chatRoomBusinessModel;
}

#pragma mark - Presentation layer
-(id<ChatRoomViewModelType>) getChatRoomViewModel {
    ChatRoomViewModel *chatRoomViewModel = [[ChatRoomViewModel alloc] initWithBusinessModel:[self getChatRoomBusinessModel]];
    return chatRoomViewModel;
}
-(id<ViewControllerType>) getChatRoomViewController {
    ChatRoomViewController *viewController = [[ChatRoomViewController alloc] initWithViewModel:[self getChatRoomViewModel]];
    return viewController;
}

@end
