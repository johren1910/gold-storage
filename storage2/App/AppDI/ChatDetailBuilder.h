//
//  ChatDetailDI.h
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import "AppEnvironment.h"
#import "ChatDetailViewModel.h"
#import "ChatDetailRemoteDataSource.h"
#import "ChatDetailLocalDataSource.h"
#import "ChatDetailDataRepository.h"
#import "ChatDetailViewController.h"

@protocol ChatDetailBuilderType
-(id<ChatDetailRemoteDataSourceType>) getChatDetailRemoteDataSource;
-(id<ChatDetailLocalDataSourceType>) getChatDetailLocalDataSource;
-(id<StorageManagerType>) getStorageManager;
-(id<ChatDetailRepositoryInterface>) getChatDetailDataRepository;
-(id<ChatDetailUseCaseInterface>) getChatDetailUseCase;
-(id<ChatDetailViewModelType>) getChatDetailViewModel:(id<ChatRoomEntityType>)roomEntity;
-(id<ViewControllerType>) getChatDetailViewController:(id<ChatRoomEntityType>)roomEntity;
@end


@interface ChatDetailBuilder : NSObject <ChatDetailBuilderType>
-(instancetype) init:(AppEnvironment*)environment;
@end
