//
//  CircleGraphView.h
//  storage2
//
//  Created by LAP14885 on 19/06/2023.
//

#import <UIKit/UIKit.h>
#import "CircleGraphComponent.h"

@interface CircleGraphView : UIView

@property (nonatomic) CGPoint centerPoint;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) NSMutableArray *circleComponents;

-(id)initWithFrame:(CGRect)frame centerPoint:(CGPoint)centerPoint lineWidth:(CGFloat)lineWidth circleComponents:(NSArray*)circleComponents;

@end
