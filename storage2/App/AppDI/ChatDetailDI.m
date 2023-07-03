//
//  ChatDetailDI.m
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatDetailDI.h"
#import "AppEnvironment.h"
#import "ChatDetailRemoteDataSource.h"
#import "ChatDetailLocalDataSource.h"
#import "ChatDetailDataRepository.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "DatabaseManager.h"
#import "ChatRoomModel.h"

@interface ChatDetailDI ()
@property (nonatomic) AppEnvironment* environment;
@end

@implementation ChatDetailDI

-(instancetype) init:(AppEnvironment*)environment {
    if (self == [super init]) {
        self.environment = environment;
    }
    return self;
}
-(ChatDetailViewModel*) chatDetailDependencies:(ChatRoomModel*)roomModel {
    
    // Data layer
    
    NSString *baseUrl = _environment.baseUrl;
    ChatDetailRemoteDataSource* remoteDataSource = [[ChatDetailRemoteDataSource alloc] init:baseUrl];
    ChatDetailLocalDataSource *localDataSource = [[ChatDetailLocalDataSource alloc] init];
    localDataSource.storageManager = _environment.storageManager;
    ChatDetailDataRepository* repository = [[ChatDetailDataRepository alloc] initWithRemote:remoteDataSource andLocal:localDataSource];
    
    // Domain layer
    ChatDetailUseCase* chatDetailUseCase = [[ChatDetailUseCase alloc] initWithRepository:repository];
    
    // Presentation layer
    ChatDetailViewModel *chatDetailViewModel = [[ChatDetailViewModel alloc] initWithChatRoom:roomModel andUsecase:chatDetailUseCase];
    
    return chatDetailViewModel;
}
@end
