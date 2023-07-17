//
//  ZODownloadRepositoryInterface.h
//  storage2
//
//  Created by LAP14885 on 04/07/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZODownloadItem.h"

@protocol ZODownloadRepositoryInterface

@property (nonatomic, copy) void(^completionBlock)(NSString* filePath);
@property (nonatomic, copy) void(^errorBlock)(NSError* error);
@property (nonatomic, copy) void(^progressBlock)(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds);
- (void)startDownloadWithItem:(id<ZODownloadItemType>)item;
- (void)pause;
- (void)resume;
- (void)cancle;

@end
