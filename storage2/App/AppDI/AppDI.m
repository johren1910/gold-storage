//
//  AppDI.m
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import <Foundation/Foundation.h>
#import "AppDI.h"
#import "AppEnvironment.h"
#import "ChatDetailBuilder.h"
#import "ChatRoomBuilder.h"
#import "ChatDetailViewController.h"

@interface AppDI ()
@property (nonatomic) AppEnvironment* environment;
@property (nonatomic) id<ChatDetailBuilderType> chatDetailBuilder;
@property (nonatomic) id<ChatRoomBuilderType> chatRoomBuilder;
@end

@implementation AppDI

+(AppDI*) shared {
    static AppDI *_appDI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _appDI = [[self alloc] init];
    });
    _appDI.environment = [[AppEnvironment alloc] init];
    _appDI.chatDetailBuilder = [[ChatDetailBuilder alloc] init:_appDI.environment];
    _appDI.chatRoomBuilder = [[ChatRoomBuilder alloc] init:_appDI.environment];
    return _appDI;
}

-(id<ViewControllerType>) getChatDetailViewController:(id<ChatRoomEntityType>)chatRoom withBuilder:(id<ChatDetailBuilderType>)builder; {
    ChatDetailViewController* viewController = nil;
    if (builder) {
        viewController = (ChatDetailViewController*)[builder getChatDetailViewController:chatRoom];
    } else {
        viewController = (ChatDetailViewController*)[[self defaultDetailBuilder] getChatDetailViewController:chatRoom];
    }
    
    return viewController;
}

-(id<ViewControllerType>) getChatRoomViewControllerWithBuilder:(id<ChatRoomBuilderType>)builder {
    ChatRoomViewController* viewController = nil;
    if (builder) {
        viewController = (ChatRoomViewController*)[builder getChatRoomViewController];
    } else {
        viewController = (ChatRoomViewController*)[[self defaultRoomBuilder] getChatRoomViewController];
    }
    
    return viewController;
}

-(id<ChatDetailBuilderType>) defaultDetailBuilder {
    return _chatDetailBuilder;
}

-(id<ChatRoomBuilderType>) defaultRoomBuilder {
    return _chatRoomBuilder;
}
@end
