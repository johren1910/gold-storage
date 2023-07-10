//
//  AppDI.h
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//
#import "AppEnvironment.h"
#import "ChatDetailViewModel.h"
#import "ChatRoomViewModel.h"
#import "ChatDetailViewController.h"
#import "ChatDetailBuilder.h"
#import "ChatRoomViewController.h"
#import "ChatRoomBuilder.h"

@protocol AppDIInterface

-(id<ViewControllerType>) getChatDetailViewController:(id<ChatRoomEntityType>)chatRoom withBuilder:(id<ChatDetailBuilderType>)builder;
-(id<ViewControllerType>) getChatRoomViewControllerWithBuilder:(id<ChatRoomBuilderType>)builder;

@end

@interface AppDI : NSObject <AppDIInterface>
-(id<ChatDetailBuilderType>) defaultDetailBuilder;
-(id<ChatRoomBuilderType>) defaultRoomBuilder;
+(AppDI*) shared;

@end
