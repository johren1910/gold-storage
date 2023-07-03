//
//  ChatRoomDI.h
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import "AppEnvironment.h"
#import "ChatRoomViewModel.h"

@interface ChatRoomDI : NSObject
-(instancetype) init:(AppEnvironment*)environment;
-(ChatRoomViewModel*) chatRoomDependencies;

@end

