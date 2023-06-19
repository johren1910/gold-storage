//
//  CircleGraphComponent.h
//  storage2
//
//  Created by LAP14885 on 19/06/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CircleGraphComponent : NSObject

@property (nonatomic) CGFloat openDegree;
@property (nonatomic) CGFloat closeDegree;
@property (nonatomic) UIColor *color;

-(id)initWithOpenDegree:(CGFloat)openDegree closeDegree:(CGFloat)closeDegree color:(UIColor*)color;

@end
