//
//  CircleGraphComponent.m
//  storage2
//
//  Created by LAP14885 on 19/06/2023.
//

#import "CircleGraphComponent.h"

@implementation CircleGraphComponent

-(id)initWithOpenDegree:(CGFloat)openDegree closeDegree:(CGFloat)closeDegree radius:(CGFloat)radius color:(UIColor*)color;
{
    self = [super init];
    if (self) {
        self.openDegree = openDegree;
        self.closeDegree = closeDegree;
        self.color = color;
        self.radius = radius;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
  return self;
}

@end
