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
-(id<StorageManagerType>) getStorageManager {
    return _environment.storageManager;
}

-(id<ChatRoomProviderType>) getChatRoomProvider {
    ChatRoomProvider* provider = [[ChatRoomProvider alloc] initWithStorageManager:[self getStorageManager]];
    return provider;
}
-(id<ChatRoomRepositoryInterface>) getChatRoomDataRepository {
    ChatRoomDataRepository* repository = [[ChatRoomDataRepository alloc] initWithStorageManager:[self getStorageManager] andChatRoomProvider:[self getChatRoomProvider]];
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
