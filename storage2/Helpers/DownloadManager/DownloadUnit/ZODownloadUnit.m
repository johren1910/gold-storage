//
//  ZODownloadUnit.m
//  storage2
//
//  Created by LAP14885 on 17/07/2023.
//

#import <Foundation/Foundation.h>
#import "ZODownloadUnit.h"

@implementation ZODOwnloadUnit
-(instancetype)initWithItem:(id<ZODownloadItemType>)item andRepository:(id<ZODownloadRepositoryInterface>)downloadRepository {
    if (self == [super init]) {
        self.downloadItem = item;
        self.downloadRepository = downloadRepository;
    }
    return self;
}
-(void)setRepository:(id<ZODownloadRepositoryInterface>)downloadRepository {
    self.downloadRepository = downloadRepository;
}
    
-(void)start:(void(^)(NSString* filePath))completionBlock errorBlock:(void(^)(NSError* error))errorBlock progressBlock:(void(^)(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds))progressBlock {
    self.downloadRepository.completionBlock = completionBlock;
    self.downloadRepository.errorBlock = errorBlock;
    self.downloadRepository.progressBlock = progressBlock;
    [self.downloadRepository startDownloadWithItem:self.downloadItem];
}
- (void)pause {
    switch (downloadItem.downloadState) {
        case ZODownloadStatePending:
        case ZODownloadStateDownloading:
        case ZODownloadStateSuspended:
            [self.downloadRepository pause];
            break;
        case ZODownloadErrorCancelled:
        case ZODownloadStateDone:
            break;
        default:
            break;
    }
}
- (void)cancle {
    switch (downloadItem.downloadState) {
        case ZODownloadStatePending:
        case ZODownloadStateError:
        case ZODownloadStateDownloading:
        case ZODownloadStateSuspended:
            [self.downloadRepository pause];
            break;
        case ZODownloadErrorCancelled:
        case ZODownloadStateDone:
            break;
        default:
            break;
    }
    [self.downloadRepository cancle];
    
}
- (void)resume {
    switch (downloadItem.downloadState) {
        case ZODownloadStatePending:
        case ZODownloadStateError:
        case ZODownloadStateSuspended:
            [self.downloadRepository resume];
            break;
        case ZODownloadStateDownloading:
        case ZODownloadErrorCancelled:
        case ZODownloadStateDone:
            break;
        default:
            break;
    }
}

- (NSComparisonResult)compare:(id<ZODownloadUnitType>)object {
    return [self.downloadItem compare:object.downloadItem];
}

@synthesize downloadItem;
@synthesize downloadRepository;

@end
