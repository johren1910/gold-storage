//
//  ChatRoomData.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

@import IGListDiffKit;
#include "ChatMessageData.h"
#include "ChatRoomEntity.h"

@interface ChatRoomData: NSObject <IGListDiffable, NSCopying>

@property (nonatomic,readwrite,copy) NSString* name;
@property (nonatomic,readwrite, copy) NSString* chatRoomId;
@property (nonatomic,readwrite) double createdAt;
@property (nonatomic) BOOL selected;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name chatRoomId:(NSString *)chatRoomId;

- (ChatRoomEntity*) toChatRoomEntity;
@end
