//
//  CircleGraphView.m
//  storage2
//
//  Created by LAP14885 on 19/06/2023.
//

#import <Foundation/Foundation.h>
#import "CircleGraphView.h"

@implementation CircleGraphView

-(id)initWithFrame:(CGRect)frame centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth circleComponents:(NSArray*)circleComponents {
    self = [super initWithFrame:frame];
        if (self) {
            self.centerPoint = centerPoint;
            self.radius = radius;
            self.lineWidth = lineWidth;
            self.circleComponents = circleComponents;
        }
        return self;
}

- (void)drawRect:(CGRect)rect {

    [self drawCircle];
}

- (void)drawCircle {

    CGFloat outerRadius = _radius;
    CGFloat insideRadius = _radius/3;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, _lineWidth);
    CircleGraphComponent *insideCircleComponent = [[CircleGraphComponent alloc] initWithOpenDegree:0 closeDegree:360 color:[UIColor whiteColor]];
    for(CircleGraphComponent *circleComponent in _circleComponents)
    {
        // Draw circle Arc
        CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);

        CGContextAddArc(context, _centerPoint.x , _centerPoint.y, outerRadius, [self radians:circleComponent.openDegree], [self radians:circleComponent.closeDegree], 0);
        CGContextSetFillColorWithColor(context, circleComponent.color.CGColor);
        CGContextFillPath(context);
        
        //Calculate Text
        CGFloat textDegree = circleComponent.closeDegree - (circleComponent.closeDegree - circleComponent.openDegree)/2;
        CGFloat textAngle = [self radians:textDegree];
        CGFloat percentage = (circleComponent.closeDegree - circleComponent.openDegree)/360 * 100;
        NSString *text = [NSString stringWithFormat:@"%.f%%", percentage];
        CATextLayer *label = [[CATextLayer alloc] init];
        [label setFont:@"Helvetica-Bold"];
        [label setFontSize:16];
        [label setString:text];
        
        CGFloat x1 = _centerPoint.x;
        CGFloat y1 = _centerPoint.y;
        CGFloat x2 = x1 + cos(textAngle) * outerRadius;
        CGFloat y2 = y1 + sin(textAngle) * outerRadius;
        
        CGFloat textCenterX = (x1 + x2)/1.5;
        CGFloat textCenterY = (y1 + y2)/1.5;
        CGFloat textWidth = 40;
        CGRect textFrame = CGRectMake(textCenterX - textWidth , textCenterY - textWidth , textWidth, textWidth);
        label.frame = textFrame;
        [self.layer addSublayer:label];
    }
    
    
    //Draw inside circle
    CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);
    CGContextAddArc(context, _centerPoint.x , _centerPoint.y, insideRadius, [self radians:insideCircleComponent.openDegree], [self radians:insideCircleComponent.closeDegree], 0);
    CGContextSetFillColorWithColor(context, insideCircleComponent.color.CGColor);
    CGContextFillPath(context);
}

-(float) radians:(double) degrees {
    return degrees * M_PI / 180;
}

@end
