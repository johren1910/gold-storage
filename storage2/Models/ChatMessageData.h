//
//  ChatMessageData.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

@import IGListDiffKit;
#import "MediaType.h"

@interface ChatMessageData: NSObject <IGListDiffable, NSCopying>

@property (nonatomic,readwrite,copy) NSString* message;
@property (nonatomic,readonly,copy) NSString* messageId;
@property (nonatomic,readonly,copy) NSString* senderId;
@property (nonatomic,readonly,copy) NSString* chatRoomId;
@property (nonatomic,readwrite) double createdAt;
@property (nonatomic,readwrite) double duration;
@property (nonatomic,readwrite) NSString* filePath;
@property (nonatomic,readwrite) double size;
@property (nonatomic,readwrite) MediaType type;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithMessage:(NSString *)message messageId:(NSString *)messageId chatRoomId:(NSString *)chatRoomId type:(MediaType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithMessage:(NSString *)message messageId:(NSString *)messageId chatRoomId:(NSString *)chatRoomId NS_DESIGNATED_INITIALIZER;

@end


