//
//  ChatRoomModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

@import IGListDiffKit;
#include "ChatMessageData.h"

@interface ChatRoomModel: NSObject <IGListDiffable, NSCopying>

@property (nonatomic,readwrite,copy) NSString* name;
@property (nonatomic,readwrite, copy) NSString* chatRoomId;
@property (nonatomic,readwrite, copy) NSArray<ChatMessageData *>* messages;
@property (nonatomic,readwrite) double size;
@property (nonatomic,readwrite) double createdAt;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name chatRoomId:(NSString *)chatRoomId;
- (instancetype)initWithName:(NSString *)name chatRoomId:(NSString *)chatRoomId messages:(NSArray<ChatMessageData*>*) messages;

@end
