//
//  Skeletonable.h
//  storage2
//
//  Created by LAP14885 on 23/06/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol Skeletonable <NSObject>

-(void) showSkeleton;
-(void) hideSkeleton;

@end

@interface SkeletonView : UIView <Skeletonable>
@end
