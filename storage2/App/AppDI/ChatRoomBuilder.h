//
//  ChatRoomDI.h
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import "AppEnvironment.h"
#import "ChatRoomViewModel.h"
#import "ChatRoomDataRepository.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "DatabaseService.h"
#import "ChatRoomViewController.h"

@protocol ChatRoomBuilderType
-(id<StorageManagerType>) getStorageManager;
-(id<ChatRoomRepositoryInterface>) getChatRoomDataRepository;
-(id<ChatRoomBusinessModelInterface>) getChatRoomBusinessModel;
-(id<ChatRoomViewModelType>) getChatRoomViewModel;
-(id<ViewControllerType>) getChatRoomViewController;

@end

@interface ChatRoomBuilder : NSObject <ChatRoomBuilderType>
-(instancetype) init:(id<AppEnvironmentType>)environment;

@end

