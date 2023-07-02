//
//  ChatDetailEntity.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatDetailEntity.h"

@implementation ChatDetailEntity

- (id)copyWithZone:(nullable NSZone *)zone
{
  return self;
}

- (id<NSObject>)diffIdentifier
{
    return _messageId;
}

- (NSUInteger)hash
{
    NSUInteger subhashes[] =  {[_messageId hash]};
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

- (BOOL)isEqual:(ChatDetailEntity *)object
{
  if (self == object && self.selected == object.selected && self.thumbnail == object.thumbnail && self.isError == object.isError) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_messageId == object->_messageId ? YES : [_messageId isEqual:object->_messageId])
    && (_selected == object->_selected)
    && (_thumbnail == object->_thumbnail)
    && (_isError == object->_isError);
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
{
  return [self isEqual:object];
}

@end

