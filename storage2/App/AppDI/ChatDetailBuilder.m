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
#import "ChatMessageProvider.h"
#import "FileDataProvider.h"
#import "ChatDetailViewController.h"

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

-(id<StorageManagerType>) getStorageManager {
    return _environment.storageManager;
}

-(id<CacheServiceType>) getCacheService {
    return _environment.cacheService;
}

-(id<ChatMessageProviderType>) getChatMessageProvider {
    ChatMessageProvider* provider = [[ChatMessageProvider alloc] initWithStorageManager:[self getStorageManager]];
    return provider;
}

-(id<FileDataProviderType>) getFileDataProvider {
    FileDataProvider* provider = [[FileDataProvider alloc] initWithStorageManager:[self getStorageManager]];
    return provider;
}

-(id<ZODownloadManagerType>) getDownloadManager {
    return _environment.downloadManager;
}

-(id<ChatDetailRepositoryInterface>) getChatDetailDataRepository {
    ChatDetailDataRepository* repository = [[ChatDetailDataRepository alloc] initWithDownloadManager:[self getDownloadManager] andFileDataProvider:[self getFileDataProvider] andChatMessageProvider:[self getChatMessageProvider] andStorageManager:[self getStorageManager]];
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
