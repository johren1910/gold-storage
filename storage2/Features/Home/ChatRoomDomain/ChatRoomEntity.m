//
//  ChatRoomEntity.m
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import "ChatRoomEntity.h"

@implementation ChatRoomEntity

- (id)copyWithZone:(nullable NSZone *)zone
{
  return self;
}

- (id<NSObject>)diffIdentifier
{
    return self.roomId;
}

- (NSUInteger)hash
{
    NSUInteger subhashes[] =  {[self.roomId hash]};
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

- (BOOL)isEqual:(ChatRoomEntity *)object
{
  if (self == object && self.selected == object.selected) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (self.roomId == object.roomId ? YES : [self.roomId isEqual:object.roomId])
    && (_selected == object->_selected);
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
{
  return [self isEqual:object];
}

@synthesize name;

@synthesize roomId;

@end

