//
//  ChatDetailDI.h
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import "AppEnvironment.h"
#import "ChatDetailViewModel.h"
#import "ChatDetailDataRepository.h"
#import "ChatDetailViewController.h"

@protocol ChatDetailBuilderType
-(id<StorageManagerType>) getStorageManager;
-(id<ChatDetailRepositoryInterface>) getChatDetailDataRepository;
-(id<ChatDetailBusinessModelInterface>) getChatDetailBusinessModel;
-(id<ChatDetailViewModelType>) getChatDetailViewModel:(id<ChatRoomEntityType>)roomEntity;
-(id<ViewControllerType>) getChatDetailViewController:(id<ChatRoomEntityType>)roomEntity;
@end


@interface ChatDetailBuilder : NSObject <ChatDetailBuilderType>
-(instancetype) init:(AppEnvironment*)environment;
@end
