//
//  Skeletonable.m
//  storage2
//
//  Created by LAP14885 on 23/06/2023.
//

#import "Skeletonable.h"

static NSString* skeletonLayerName = @"skeletonLayer";
static NSString* gradientLayerName = @"gradientLayer";

@implementation SkeletonView

- (void)hideSkeleton {
    for (CALayer* layer in self.layer.sublayers) {
        if ([[layer name] isEqualToString:skeletonLayerName] || [[layer name] isEqualToString:gradientLayerName]) {
            [layer removeFromSuperlayer];
        }
    }
}

- (void)showSkeleton {
    UIColor *backgroundColor = [[UIColor alloc] initWithRed:210.0/255.0 green: 210.0/255.0 blue: 210.0/255.0 alpha: 1.0];
    
    UIColor *highlightColor = [[UIColor alloc] initWithRed:235/255.0 green: 235/255.0 blue: 235/255.0 alpha: 1.0];
    
    CALayer *skeletonLayer = [[CALayer alloc] init];
    
    [skeletonLayer setBackgroundColor:backgroundColor.CGColor];
    skeletonLayer.name = skeletonLayerName;
    skeletonLayer.anchorPoint = CGPointZero;
    [skeletonLayer setFrame:self.bounds];
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    
    gradientLayer.colors = @[(id)backgroundColor.CGColor, (id)highlightColor.CGColor, (id)backgroundColor.CGColor];
    
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    gradientLayer.frame = self.bounds;
    gradientLayer.name = gradientLayerName;
    
    [self.layer setMask:skeletonLayer];
    [self.layer addSublayer:skeletonLayer];
    [self.layer addSublayer:gradientLayer];
    self.clipsToBounds = TRUE;
    NSNumber *fromValue = [[NSNumber alloc] initWithFloat:-self.bounds.size.width];
    NSNumber *toValue = [[NSNumber alloc] initWithFloat:self.bounds.size.width];
    
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"transform.translation.x";
    animation.duration = 3;
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.repeatCount = INFINITY;
    animation.autoreverses = FALSE;
    animation.fillMode = kCAFillModeForwards;
    
    [gradientLayer addAnimation:animation forKey:@"gradientLayerShimmerAnimation"];
}


@end
