//
//  ChatMessageData.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "ChatMessageData.h"
#import "MediaType.h"
@implementation ChatMessageData

- (instancetype)initWithMessage:(NSString *)message messageId:(NSString *)messageId chatRoomId:(NSString *)chatRoomId type:(MediaType)type
{
  if ((self = [super init])) {
    _message = [message copy];
    _messageId = [messageId copy];
    _type = type;
      _chatRoomId = [chatRoomId copy];
  }

  return self;
}

- (instancetype)initWithMessage:(NSString *)message messageId:(NSString *)messageId chatRoomId:(NSString *)chatRoomId
{
 if ((self = [super init])) {
   _message = [message copy];
   _messageId = [messageId copy];
     _type = Other;
     _chatRoomId = [chatRoomId copy];
 }

 return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - \n\t name: %@; \n\t messageId: %@; \n type: @type", [super description], _message, _messageId, _type];
}

- (id<NSObject>)diffIdentifier
{
  return _messageId;
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_message hash], [_messageId hash]};
  NSUInteger result = subhashes[0];
  for (int ii = 1; ii < 3; ++ii) {
    unsigned long long base = (((unsigned long long)result) << 32 | subhashes[ii]);
    base = (~base) + (base << 18);
    base ^= (base >> 31);
    base *=  21;
    base ^= (base >> 11);
    base += (base << 6);
    base ^= (base >> 22);
    result = base;
  }
  return result;
}

- (BOOL)isEqual:(ChatMessageData *)object
{
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_message == object->_message ? YES : [_message isEqual:object->_message]) &&
    (_messageId == object->_messageId ? YES : [_messageId isEqual:object->_messageId]);
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
{
  return [self isEqual:object];
}

@end
