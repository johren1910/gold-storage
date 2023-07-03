//
//  ChatRoomDI.m
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomDI.h"
#import "ChatDetailRemoteDataSource.h"
#import "ChatDetailLocalDataSource.h"
#import "ChatDetailDataRepository.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "DatabaseManager.h"
#import "ChatRoomModel.h"

@interface ChatRoomDI ()
@property (nonatomic) AppEnvironment* environment;
@end

@implementation ChatRoomDI

-(instancetype) init:(AppEnvironment*)environment {
    if (self == [super init]) {
        self.environment = environment;
    }
    return self;
}
-(ChatRoomViewModel*) chatRoomDependencies {
    
    // Data layer
    NSString *baseUrl = _environment.baseUrl;
    
    // Domain layer
    
    
    // Presentation layer
    ChatRoomViewModel *chatRoomViewModel = [[ChatRoomViewModel alloc] init];
    chatRoomViewModel.storageManager = _environment.storageManager;
    chatRoomViewModel.downloadManager = _environment.downloadManager;
    
    return chatRoomViewModel;
    
}
@end

