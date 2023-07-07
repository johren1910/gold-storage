//
//  ChatDetailDI.h
//  storage2
//
//  Created by LAP14885 on 03/07/2023.
//

#import "AppEnvironment.h"
#import "ChatDetailViewModel.h"

@interface ChatDetailDI : NSObject
-(instancetype) init:(AppEnvironment*)environment;
-(ChatDetailViewModel*) chatDetailDependencies:(ChatRoomEntity*)roomData;

@end
