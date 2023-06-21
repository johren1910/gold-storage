//
//  CircleGraphView.m
//  storage2
//
//  Created by LAP14885 on 19/06/2023.
//

#import <Foundation/Foundation.h>
#import "CircleGraphView.h"

@interface CircleGraphView ()
@property (nonatomic) NSMutableArray<UIBezierPath *>* paths;
@property (nonatomic) int focusedIndex;
-(void)updateCircleComponents:(NSArray*)circleComponents;
-(void)drawCircleComponent:(CircleGraphComponent*)component context:(CGContextRef)context label:(CATextLayer*)label;
@end

@implementation CircleGraphView

-(id)initWithFrame:(CGRect)frame centerPoint:(CGPoint)centerPoint lineWidth:(CGFloat)lineWidth circleComponents:(NSArray*)circleComponents {
    self = [super initWithFrame:frame];
    if (self) {
        self.centerPoint = centerPoint;
        self.lineWidth = lineWidth;
        self.circleComponents = [circleComponents mutableCopy];
        self.paths = [@[] mutableCopy];
        self.focusedIndex = -1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [self drawCircle];
}

-(void)drawCircleComponent:(CircleGraphComponent*)component context:(CGContextRef)context  label:(CATextLayer*)label {
    
    CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);
    CGContextAddArc(context, _centerPoint.x , _centerPoint.y, component.radius, [self radians:component.openDegree], [self radians:component.closeDegree], 0);

    CGPathRef path = CGContextCopyPath(context);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path];
    [_paths addObject:bezierPath];

    CGContextSetFillColorWithColor(context, component.color.CGColor);
    CGContextFillPath(context);
    
    if (label != nil) {
        CGFloat textDegree = component.closeDegree - (component.closeDegree - component.openDegree)/2;
        CGFloat textAngle = [self radians:textDegree];
        
        CGFloat x1 = _centerPoint.x;
        CGFloat y1 = _centerPoint.y;
        CGFloat x2 = x1 + cos(textAngle) * component.radius;
        CGFloat y2 = y1 + sin(textAngle) * component.radius;
        
        CGFloat textCenterX = (x1 + x2)/1.5;
        CGFloat textCenterY = (y1 + y2)/1.5;
        CGFloat textWidth = 40;
        CGRect textFrame = CGRectMake(textCenterX - textWidth , textCenterY - textWidth , textWidth, textWidth);
        label.frame = textFrame;
        [self.layer addSublayer:label];
    }
    
    // ANIMATION SCALE
//    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
//    animation.keyPath = @"transform.scale";
//    animation.repeatCount = 10;
//    animation.duration = 1l;
//    animation.toValue = @(1.5);
//    CAMediaTimingFunction *timingFunction =
//    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [animation setTimingFunction:timingFunction];
//    animation.autoreverses = true;
//    [self.layer addAnimation:animation forKey:nil];
    
}

-(void)updateCircleComponents:(NSArray*)circleComponents {
    [_paths removeAllObjects];
    _circleComponents = [circleComponents mutableCopy];
    self.layer.sublayers = nil;
    [self.layer removeAllAnimations];
    [CATransaction setDisableActions:TRUE];
    [CATransaction flush];
    [self setNeedsDisplay];
}

-(void)updateCircleComponentAtIndex:(int)index withComponent:(CircleGraphComponent*)component {
    [_paths removeAllObjects];
    _circleComponents[index] = component;
    self.layer.sublayers = nil;
    [self.layer removeAllAnimations];
    [CATransaction setDisableActions:TRUE];
    [CATransaction flush];
    [self setNeedsDisplay];
}

- (void)drawCircle {
    
    self.clearsContextBeforeDrawing = TRUE;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, _lineWidth);

    CircleGraphComponent *insideCircleComponent = [[CircleGraphComponent alloc] initWithOpenDegree:0 closeDegree:360 radius:30 color:[UIColor whiteColor]];
    for(CircleGraphComponent *circleComponent in _circleComponents)
    {
        CGFloat percentage = (circleComponent.closeDegree - circleComponent.openDegree)/360 * 100;
        NSString *text = [NSString stringWithFormat:@"%.f%%", percentage];
        CATextLayer *label = [[CATextLayer alloc] init];
        [label setFont:@"Helvetica-Bold"];
        [label setFontSize:16];
        [label setString:text];
        
        // Draw circle Arc
        [self drawCircleComponent:circleComponent context:context label:label];
    }
    
    
    //Draw inside circle
    [self drawCircleComponent:insideCircleComponent context:context label:nil];
}

-(float) radians:(double) degrees {
    return degrees * M_PI / 180;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint location = [[touches anyObject] locationInView:self];
    CGRect fingerRect = CGRectMake(location.x-5, location.y-5, 10, 10);
    
    NSUInteger index = 0;
    for(UIBezierPath *path in _paths)
    {
        
        if ([path containsPoint:fingerRect.origin]) {
            NSLog(@"CONTAIN at index %lu", (unsigned long)index);
            
            //TODO: Handle animation
//            CircleGraphComponent *selectedComponent = [_circleComponents[index] copy];
//            selectedComponent.radius = selectedComponent.radius * 1.1;
//
//            [self updateCircleComponentAtIndex:index withComponent:selectedComponent];
            
            break;
        }
        
        
        index+=1;
    }
}

@end
