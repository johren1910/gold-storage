//
//  ZODownloadUnit.h
//  storage2
//
//  Created by LAP14885 on 25/06/2023.
//

#import <Foundation/Foundation.h>
#import "ZODownloadUnit.h"

typedef void(^ZODownloadProgressBlock)(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds);
typedef void(^ZODownloadCompletionBlock)(NSString *destinationPath);
typedef void(^ZODownloadErrorBlock)(NSError *error);

typedef NS_ENUM(NSUInteger,ZODownloadState) {
    
    ZODownloadStateUnknown            = 1,
    ZODownloadStatePending            = 2,
    ZODownloadStateDownloading        = 3,
    ZODownloadStateSuspended    = 4,
    ZODownloadStateDone     = 5,
    ZODownloadStateError              = 6
};

typedef NS_ENUM(NSUInteger,ZODownloadPriority) {
    
    ZODownloadPriorityNormal            = 1,
    ZODownloadPriorityHigh            = 2,
    // For retry
    ZODownloadPriorityRetryImmediate            = 3
};

typedef NS_ENUM(NSUInteger,ZODownloadErrorCode) {
    
    ZODownloadErrorNoInternet            = -1009,
    ZODownloadErrorNoTimeoutRequest            = -1001,
    ZODownloadErrorCancelled        = -999,
    ZODownloadErrorNetworkConnectionList        = -1005
};

/// This interface provide details info for a download
@interface ZODownloadUnit : NSObject
/// [This property is] define unique id of each download unit
@property (nonatomic, readonly) NSString* downloadId;

/// [This property is] define url that the client request to be downloaded
@property (nonatomic, copy) NSString *requestUrl;

/// [This property is] define the destination directory where the files will be downloaded to
///  - Note: Default is DocumentDirectory
@property (nonatomic, copy) NSString *destinationDirectoryPath;

/// [This property is] hold the task of the according requestUrl
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

/// [This property is] define the destination directory where the files will be downloaded to
///  - Note: Default is DocumentDirectory
@property (nonatomic, strong) NSError *downloadError;

/// [This property is] retain the temp file path where the temporary files will be downloaded to
@property (nonatomic, copy) NSString *tempFilePath;

/// [This property is] define the nature of urlsession to be default or background
///  - Note: Default is false
@property (nonatomic) BOOL isBackgroundSession;

/// [This property is] retain the time when the download task start
@property (copy, nonatomic) NSDate *startDate;

/// [This property is] retain the resume data when the download task pause.
@property (copy, nonatomic) NSData *resumeData;

/// [This property is] define whether the error with resume data on didComplete is valid
@property (copy, nonatomic) NSData *isValidResumeData;

/// [This property is] retain progressBlock of the task to notify the manager
@property (nonatomic, strong) ZODownloadProgressBlock progressBlock;

/// [This property is] retain completionBlock of the task to notify the manager
@property (nonatomic, strong) NSMutableArray<ZODownloadCompletionBlock>* completionBlocks;

/// [This property is] retain errorBlock of the task to notify the manager
@property (nonatomic, strong) NSMutableArray<ZODownloadErrorBlock>* errorBlocks;

/// [This property is] retain downloadState of the task to notify the manager
@property (nonatomic, assign) ZODownloadState downloadState;

/// [This property is]  priority of the task. Higher priority start download first
@property (nonatomic, assign) ZODownloadPriority priority;

/// [This property is]  maxinum number of retry before return as error
@property (nonatomic, assign) int maxRetryCount;

/// [This property is]  the current retry attemp fo the unit
@property (nonatomic, assign) int currentRetryAttempt;

/// [This function  is] compare priority of the task to
- (NSComparisonResult)compare:(ZODownloadUnit *)object;
@end
