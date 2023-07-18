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
@property (nonatomic) id<AppEnvironmentType> environment;

@property (nonatomic) id<ChatMessageProviderType> chatMessageProvider;
@property (nonatomic) id<FileDataProviderType> fileDataProvider;
@property (nonatomic) id<ChatDetailRepositoryInterface> chatDetailRepository;
@property (nonatomic) id<ChatDetailBusinessModelInterface> chatDetailBusinessModel;
@property (nonatomic) NSMutableArray<id<ChatDetailViewModelType>>* chatDetailViewModels;
@end

@implementation ChatDetailBuilder

-(instancetype) init:(id<AppEnvironmentType>)environment {
    if (self == [super init]) {
        self.environment = environment;
        self.chatDetailViewModels = [[NSMutableArray alloc] init];
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
    if(_chatMessageProvider) {
        return _chatMessageProvider;
    }
    ChatMessageProvider* provider = [[ChatMessageProvider alloc] initWithStorageManager:[self getStorageManager]];
    _chatMessageProvider = provider;
    return _chatMessageProvider;
}

-(id<FileDataProviderType>) getFileDataProvider {
    if(_fileDataProvider) {
        return _fileDataProvider;
    }
    FileDataProvider* provider = [[FileDataProvider alloc] initWithStorageManager:[self getStorageManager]];
    _fileDataProvider = provider;
    return _fileDataProvider;
}

-(id<ZODownloadManagerType>) getDownloadManager {
    return _environment.downloadManager;
}

-(id<ChatDetailRepositoryInterface>) getChatDetailDataRepository {
    
    if(_chatDetailRepository) {
        return _chatDetailRepository;
    }
    ChatDetailDataRepository* repository = [[ChatDetailDataRepository alloc] initWithDownloadManager:[self getDownloadManager] andFileDataProvider:[self getFileDataProvider] andChatMessageProvider:[self getChatMessageProvider] andStorageManager:[self getStorageManager]];
    
    _chatDetailRepository = repository;
    return _chatDetailRepository;
}
-(id<ChatDetailBusinessModelInterface>) getChatDetailBusinessModel {
    if(_chatDetailBusinessModel){
        return _chatDetailBusinessModel;
    }
    
    ChatDetailBusinessModel* chatDetailBusinessModel = [[ChatDetailBusinessModel alloc] initWithRepository:[self getChatDetailDataRepository]];
    _chatDetailBusinessModel = chatDetailBusinessModel;
    return _chatDetailBusinessModel;
    
}
-(id<ChatDetailViewModelType>) getChatDetailViewModel:(id<ChatRoomEntityType>)roomEntity {
    id<ChatDetailViewModelType> resultViewModel;
    if(_chatDetailViewModels.count>0) {
        for (id<ChatDetailViewModelType> viewModel in _chatDetailViewModels) {
            if(viewModel.filteredChats.count==0){
                resultViewModel = viewModel;
                break;
            }
        }
    }
    
    if(resultViewModel) {
        [resultViewModel setChatRoom:roomEntity];
        return resultViewModel;
    }
    
    ChatDetailViewModel *chatDetailViewModel = [[ChatDetailViewModel alloc] initWithChatRoom:roomEntity andBusinessModel:[self getChatDetailBusinessModel]];
    [_chatDetailViewModels addObject:chatDetailViewModel];
    return chatDetailViewModel;
}
-(id<ViewControllerType>) getChatDetailViewController:(id<ChatRoomEntityType>)roomEntity {
    ChatDetailViewController *viewController = [[ChatDetailViewController alloc] initWithViewModel:[self getChatDetailViewModel:roomEntity]];
    viewController.title = roomEntity.name;
    return viewController;
}

@end
