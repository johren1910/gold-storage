//
//  AppDI.h
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//
#import "AppEnvironment.h"
#import "ChatDetailViewModel.h"
#import "ChatRoomViewModel.h"

@protocol AppDIInterface

-(ChatDetailViewModel*) chatDetailDependencies:(ChatRoomEntity*)roomData;
-(ChatRoomViewModel*) chatRoomDependencies;

@end

@interface AppDI : NSObject <AppDIInterface>

+(AppDI*) shared;

@end
