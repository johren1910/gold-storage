//
//  ZODownloadRepositoryInterface.h
//  storage2
//
//  Created by LAP14885 on 04/07/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZODownloadUnit.h"


@protocol ZODownloadRepositoryInterface

@property (nonatomic, copy) void(^completionBlock)(NSString* filePath, ZODownloadUnit* unit);
@property (nonatomic, copy) void(^errorBlock)(NSError* error, ZODownloadUnit* unit);
- (void)startDownloadWithUnit:(ZODownloadUnit*)unit completionBlock:(void(^)(BOOL isDownloadStarted))completionBlock;
- (void)suspendDownloadOfUrl:(NSString *)url;
- (void)suspendAllDownload;
- (void)resumeDownloadOfUrl:(NSString *)url;
- (void)resumeAllDownload;
- (void)cancelDownloadOfUrl:(NSString *)url;
- (void)cancelAllDownload;


@end
