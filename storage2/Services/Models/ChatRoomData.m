//
//  ChatRoomData.m
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import "ChatRoomData.h"

@implementation ChatRoomData

- (instancetype)initWithName:(NSString *)name chatRoomId:(NSString *)chatRoomId
{
    if ((self = [super init])) {
      _name = [name copy];
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
  return [NSString stringWithFormat:@"%@ - \n\t name: %@; \n\t chatRoomId: %@; \n", [super description], _name, _chatRoomId];
}

- (id<NSObject>)diffIdentifier
{
  return _chatRoomId;
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_name hash], [_chatRoomId hash]};
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

- (BOOL)isEqual:(ChatRoomData *)object
{
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_name == object->_name ? YES : [_name isEqual:object->_name]) &&
    (_chatRoomId == object->_chatRoomId ? YES : [_chatRoomId isEqual:object->_chatRoomId]);
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
{
  return [self isEqual:object];
}

- (ChatRoomEntity*) toChatRoomEntity {
    ChatRoomEntity* entity = [[ChatRoomEntity alloc] init];
    entity.roomId = self.chatRoomId;
    entity.name = self.name;
    entity.selected = self.selected;
    return entity;
}

@end
