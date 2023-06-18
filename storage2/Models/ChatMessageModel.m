//
//  ChatMessageModel.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "ChatMessageModel.h"
#import "MediaType.h"
@implementation ChatMessageModel

- (instancetype)initWithName:(NSString *)name chatId:(NSString *)chatId type:(MediaType)type
{
  if ((self = [super init])) {
    _name = [name copy];
    _messageId = [chatId copy];
    _type = type;
  }

  return self;
}

- (instancetype)initWithName:(NSString *)name chatId:(NSString *)chatId
{
 if ((self = [super init])) {
   _name = [name copy];
   _messageId = [chatId copy];
     _type = File;
 }

 return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - \n\t name: %@; \n\t chatId: %@; \n type: @type", [super description], _name, _messageId, _type];
}

- (id<NSObject>)diffIdentifier
{
  return _messageId;
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_name hash], [_messageId hash]};
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
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_name == object->_name ? YES : [_name isEqual:object->_name]) &&
    (_messageId == object->_messageId ? YES : [_messageId isEqual:object->_messageId]);
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
{
  return [self isEqual:object];
}

@end
