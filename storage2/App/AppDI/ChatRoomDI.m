//
//  ChatRoomDI.m
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomDI.h"
#import "ChatRoomRemoteDataSource.h"
#import "ChatRoomLocalDataSource.h"
#import "ChatRoomDataRepository.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "DatabaseService.h"

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
    ChatRoomRemoteDataSource* remoteDataSource = [[ChatRoomRemoteDataSource alloc] init:baseUrl];
    
    ChatRoomLocalDataSource *localDataSource = [[ChatRoomLocalDataSource alloc] init];
    localDataSource.storageManager = _environment.storageManager;
    ChatRoomDataRepository* repository = [[ChatRoomDataRepository alloc] initWithRemote:remoteDataSource andLocal:localDataSource andStorageManager:_environment.storageManager];
    
    // Domain layer
    ChatRoomUseCase* chatRoomUseCase = [[ChatRoomUseCase alloc] initWithRepository:repository];
    
    // Presentation layer
    ChatRoomViewModel *chatRoomViewModel = [[ChatRoomViewModel alloc] initWithUseCase:chatRoomUseCase];
    
    return chatRoomViewModel;
}

@end

