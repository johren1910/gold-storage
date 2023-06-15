//
//  HomeViewModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>
#import "ChatModel.h"

@interface HomeViewModel : NSObject

- (instancetype)initWithChats:(__weak ChatModel *[])chats;

@end
