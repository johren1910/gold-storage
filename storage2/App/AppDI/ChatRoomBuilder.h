//
//  ChatRoomDI.h
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import "AppEnvironment.h"
#import "ChatRoomViewModel.h"
#import "ChatRoomRemoteDataSource.h"
#import "ChatRoomLocalDataSource.h"
#import "ChatRoomDataRepository.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "DatabaseService.h"
#import "ChatRoomViewController.h"

@protocol ChatRoomBuilderType
-(id<ChatRoomRemoteDataSourceType>) getChatRoomRemoteDataSource;
-(id<ChatRoomLocalDataSourceType>) getChatRoomLocalDataSource;
-(id<StorageManagerType>) getStorageManager;
-(id<ChatRoomRepositoryInterface>) getChatRoomDataRepository;
-(id<ChatRoomUseCaseInterface>) getChatRoomUseCase;
-(id<ChatRoomViewModelType>) getChatRoomViewModel;
-(id<ViewControllerType>) getChatRoomViewController;

@end

@interface ChatRoomBuilder : NSObject <ChatRoomBuilderType>
-(instancetype) init:(AppEnvironment*)environment;

@end

