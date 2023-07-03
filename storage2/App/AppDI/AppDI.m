//
//  AppDI.m
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import "AppDI.h"
#import "AppEnvironment.h"
#import "ChatDetailDI.h"
#import "ChatRoomDI.h"

@interface AppDI ()
@property (nonatomic) AppEnvironment* environment;
@end

@implementation AppDI

+(AppDI*) shared {
    static AppDI *_appDI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _appDI = [[self alloc] init];
    });
    _appDI.environment = [[AppEnvironment alloc] init];
    return _appDI;
}

-(ChatDetailViewModel*) chatDetailDependencies:(ChatRoomModel*)roomModel {
    
    ChatDetailDI* chatDetailDI = [[ChatDetailDI alloc] init:_environment];
    
    ChatDetailViewModel* viewModel = [chatDetailDI chatDetailDependencies:roomModel];
    
    return viewModel;
    
}
-(ChatRoomViewModel*) chatRoomDependencies {
    ChatRoomDI* chatRoomDI = [[ChatRoomDI alloc] init:_environment];
    
    ChatRoomViewModel* viewModel = [chatRoomDI chatRoomDependencies];
    
    return viewModel;
}
@end
