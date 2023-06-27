//
//  ChatMessageModel.m
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//
#import "ChatMessageModel.h"

@implementation ChatMessageModel

- (instancetype)initWithMessageData:(ChatMessageData *)messageData thumbnail:(UIImage *)thumbnail
{
  if ((self = [super init])) {
    _messageData = [messageData copy];
    _thumbnail = [thumbnail copy];
  }

  return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
  return self;
}

- (id<NSObject>)diffIdentifier
{
  return _messageData.messageId;
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_messageData.message hash], [_messageData.messageId hash]};
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

- (BOOL)isEqual:(ChatMessageModel *)object
{
  if (self == object && self.selected == object.selected && self.thumbnail == object.thumbnail) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_messageData.message == object->_messageData.message ? YES : [_messageData.message isEqual:object->_messageData.message]) &&
    (_messageData.messageId == object->_messageData.messageId ? YES : [_messageData.messageId isEqual:object->_messageData.messageId])
    && (_selected == object->_selected)
    && (_thumbnail == object->_thumbnail);
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
{
  return [self isEqual:object];
}

@end
