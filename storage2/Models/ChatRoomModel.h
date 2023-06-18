//
//  ChatRoomModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

@import IGListDiffKit;
#include "ChatMessageModel.h"

@interface ChatRoomModel: NSObject <IGListDiffable, NSCopying>

@property (nonatomic,readwrite,copy) NSString* name;
@property (nonatomic,readwrite, copy) NSString* chatId;
@property (nonatomic,readwrite, copy) NSArray<ChatMessageModel *>* messages;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name chatId:(NSString *)chatId;
- (instancetype)initWithName:(NSString *)name chatId:(NSString *)chatId messages:(NSArray<ChatMessageModel*>*) messages;

@end
