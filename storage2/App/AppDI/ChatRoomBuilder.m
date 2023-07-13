//
//  ChatRoomDI.m
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomBuilder.h"
#import "ChatRoomProvider.h"

@interface ChatRoomBuilder ()
@property (nonatomic) id<AppEnvironmentType> environment;
@property (nonatomic) id<ChatRoomProviderType> chatRoomProvider;
@property (nonatomic) id<ChatRoomRepositoryInterface> chatRoomDataRepository;
@property (nonatomic) id<ChatRoomBusinessModelInterface> chatRoomBusinessModel;
@property (nonatomic) id<ChatRoomViewModelType> chatRoomViewModel;
@end

@implementation ChatRoomBuilder

-(instancetype) init:(id<AppEnvironmentType>)environment {
    if (self == [super init]) {
        self.environment = environment;
    }
    return self;
}

#pragma mark - Data layer
-(id<StorageManagerType>) getStorageManager {
    return _environment.storageManager;
}

-(id<ChatRoomProviderType>) getChatRoomProvider {
    if(_chatRoomProvider){
        return _chatRoomProvider;
    }
    ChatRoomProvider* provider = [[ChatRoomProvider alloc] initWithStorageManager:[self getStorageManager]];
    _chatRoomProvider = provider;
    return _chatRoomProvider;
}
-(id<ChatRoomRepositoryInterface>) getChatRoomDataRepository {
    if(_chatRoomDataRepository)
        return _chatRoomDataRepository;
    ChatRoomDataRepository* repository = [[ChatRoomDataRepository alloc] initWithStorageManager:[self getStorageManager] andChatRoomProvider:[self getChatRoomProvider]];
    _chatRoomDataRepository = repository;
    return _chatRoomDataRepository;
}

#pragma mark - Domain layer
-(id<ChatRoomBusinessModelInterface>) getChatRoomBusinessModel {
    if(_chatRoomBusinessModel)
        return _chatRoomBusinessModel;
    ChatRoomBusinessModel* chatRoomBusinessModel = [[ChatRoomBusinessModel alloc] initWithRepository:[self getChatRoomDataRepository]];
    _chatRoomBusinessModel = chatRoomBusinessModel;
    return _chatRoomBusinessModel;
}

#pragma mark - Presentation layer
-(id<ChatRoomViewModelType>) getChatRoomViewModel {
    if(_chatRoomViewModel)
        return _chatRoomViewModel;
    ChatRoomViewModel *chatRoomViewModel = [[ChatRoomViewModel alloc] initWithBusinessModel:[self getChatRoomBusinessModel]];
    _chatRoomViewModel = chatRoomViewModel;
    return _chatRoomViewModel;
}
-(id<ViewControllerType>) getChatRoomViewController {
    ChatRoomViewController *viewController = [[ChatRoomViewController alloc] initWithViewModel:[self getChatRoomViewModel]];
    return viewController;
}

@end
