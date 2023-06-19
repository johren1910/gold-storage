//
//  CircleGraphComponent.m
//  storage2
//
//  Created by LAP14885 on 19/06/2023.
//

#import "CircleGraphComponent.h"

@implementation CircleGraphComponent

-(id)initWithOpenDegree:(CGFloat)openDegree closeDegree:(CGFloat)closeDegree color:(UIColor*)color;
{
    self = [super init];
    if (self) {
        self.openDegree = openDegree;
        self.closeDegree = closeDegree;
        self.color = color;
    }
    return self;
}

@end
