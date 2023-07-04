//
//  ZOUrlSessionDownloadRepository.m
//  storage2
//
//  Created by LAP14885 on 04/07/2023.
//

#import "AppDelegate.h"
#import "ZOUrlSessionDownloadRepostiory.h"
#import "FileHelper.h"

@interface ZOUrlSessionDownloadRepository () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *defaultUrlSession;
@property (nonatomic, strong) NSURLSession *backgroundUrlSession;
@property (nonatomic, strong) NSMutableDictionary *currentDownloadUnits;

@end

@implementation ZOUrlSessionDownloadRepository

- (instancetype)init {
    if (self == [super init]) {
        self.currentDownloadUnits = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)cancelDownloadOfUrl:(NSString *)url {
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    ZOUrlSessionDownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:url];
    
    if (unit) {
        if (unit.downloadState == ZODownloadStateDone) {
            return;
        } else {
            if (unit.downloadState == ZODownloadStateDownloading) {
                //                weakself.currentDownloadingCount--;
            }
            [unit.task cancel];
            unit.task = nil;
        }
        [weakself.currentDownloadUnits removeObjectForKey:url];
        //        [weakself.priorityQueue remove:unit];
    }
    
    //    [weakself checkDownloadPipeline];
}

- (void)cancelAllDownload {
    [self.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZOUrlSessionDownloadUnit* value, BOOL* stop) {
        [value.task cancel];
        value.task = nil;
        [FileHelper removeItemAtPath:value.tempFilePath];
    }];

    [self.currentDownloadUnits removeAllObjects];
}

- (void)resumeAllDownload {
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    [weakself.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZODownloadUnit* value, BOOL* stop) {
        if (value.downloadState != ZODownloadStateError || value.downloadState != ZODownloadStateDone || value.downloadState != ZODownloadStateDownloading ) {
            value.downloadState = ZODownloadStatePending;
        }
    }];
    
}

- (void)resumeDownloadOfUrl:(NSString *)url {
    if (url.length == 0) {
        return;
    }
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    ZOUrlSessionDownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:url];
    if (unit) {
        if (unit.task) {
            if (unit.downloadError) {
                [unit.task cancel];
                unit.task = nil;
                unit.downloadError = nil;
            }
        }
    }
}

- (void)startDownloadWithUnit:(ZODownloadUnit *)unit completionBlock:(void(^)(BOOL isDownloadStarted) )completionBlock {
    
    ZOUrlSessionDownloadUnit* sessionUnit = [[ZOUrlSessionDownloadUnit alloc] initWithUnit:unit];
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    if (!sessionUnit.task) {
        NSLog(@"4");
    }
    sessionUnit.downloadState = ZODownloadStateDownloading;
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if (sessionUnit.isBackgroundSession) {
        [[weakself _getUrlSessionBasedOnUnit:sessionUnit] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            [downloadTasks enumerateObjectsUsingBlock:^(id task, NSUInteger idx, BOOL *stop) {
                NSURLSessionTask *sessionTask = (NSURLSessionTask*) task;
                if ([sessionUnit.requestUrl isEqualToString:sessionTask.originalRequest.URL.absoluteString]) {
                    
                    if (sessionTask.state == NSURLSessionTaskStateCompleted
                        && sessionTask.error) {
                        // App terminated manully by user. All background session download cleared, create new download
                        [sessionTask cancel];
                    } else {
                        sessionUnit.task = (NSURLSessionDownloadTask*)sessionTask;
                        [weakself.currentDownloadUnits setObject:unit forKey:sessionUnit.requestUrl];
                        if (sessionTask.state == NSURLSessionTaskStateSuspended) {
                            [sessionTask resume];
                            completionBlock(TRUE);
                        }
                    }
                }
            }];
            
            if (!sessionUnit.task) {
                NSURLSessionDownloadTask *downloadTask = [weakself _createDownloadTaskWithUnit:unit];
                
                sessionUnit.task = downloadTask;
                [weakself.currentDownloadUnits setObject:sessionUnit forKey:sessionUnit.requestUrl];
                [downloadTask resume];
                completionBlock(TRUE);
                
            }
        }];
    } else {
        NSURLSessionDownloadTask *downloadTask = [weakself _createDownloadTaskWithUnit:sessionUnit];
        //        weakself.currentDownloadingCount++;
        sessionUnit.task = downloadTask;
        [weakself.currentDownloadUnits setObject:sessionUnit forKey:sessionUnit.requestUrl];
        completionBlock(TRUE);
        [downloadTask resume];
    }
}

- (void)suspendDownloadOfUrl:(NSString *)url {
    ZOUrlSessionDownloadUnit *unit = [self.currentDownloadUnits objectForKey:url];
    if (unit) {
        [unit.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if (resumeData) {
                unit.resumeData = resumeData;
            }
        }];
        unit.downloadState = ZODownloadStateSuspended;
    }
}

- (void)suspendAllDownload {
    
}

@synthesize errorBlock;
@synthesize completionBlock;

#pragma mark - Private helpers

- (NSURLSession*) _getUrlSessionBasedOnUnit:(ZODownloadUnit*)unit {
    if (unit.isBackgroundSession) {
        return self._getBackgroundUrlSession;
    } else {
        return self._getDefaultUrlSession;
    }
}

- (NSURLSession *)_getBackgroundUrlSession {
    if (!_backgroundUrlSession) {
        NSURLSessionConfiguration *backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.zodownloadmanager.backgroundsession"];
        backgroundConfig.discretionary = true;
        backgroundConfig.sessionSendsLaunchEvents = true;
        _backgroundUrlSession = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:self delegateQueue:nil];
    }
    
    return _backgroundUrlSession;
}

- (NSURLSession *)_getDefaultUrlSession {
    if (!_defaultUrlSession) {
        NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultConfig.waitsForConnectivity = NO;  // waits for connectitity, don't notify error immediately.
        defaultConfig.timeoutIntervalForRequest = 5;
        _defaultUrlSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:self delegateQueue:nil];
    }
    return _defaultUrlSession;
}

- (NSURLSessionDownloadTask *)_createDownloadTaskWithUnit:(ZODownloadUnit *)unit {
    NSURL *url = [NSURL URLWithString:unit.requestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask;
    if (unit.resumeData) {
        downloadTask = [[self _getUrlSessionBasedOnUnit:unit] downloadTaskWithResumeData:unit.resumeData];
    } else {
        downloadTask = [[self _getUrlSessionBasedOnUnit:unit] downloadTaskWithRequest:request];
    }
    return downloadTask;
}

- (NSUInteger)remainingTimeForDownload:(ZODownloadUnit *)unit
                      bytesTransferred:(int64_t)bytesTransferred
             totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:unit.startDate];
    CGFloat speed = (CGFloat)bytesTransferred / (CGFloat)timeInterval;
    CGFloat remainingBytes = totalBytesExpectedToWrite - bytesTransferred;
    CGFloat remainingTime = remainingBytes / speed;
    
    return (NSUInteger)remainingTime;
}

- (void)_cancelTaskOfUnit:(ZOUrlSessionDownloadUnit *)unit {
    
    if (unit.task) {
        [unit.task cancel];
        unit.task = nil;
    }
    unit.downloadError = nil;
}

- (BOOL)_retryWithUrl:(NSString *)url {
    return false;
}

#pragma mark - NSURLSessionDelegate, NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    NSString *urlString = downloadTask.currentRequest.URL.absoluteString;
    if (!urlString) {
        urlString = downloadTask.originalRequest.URL.absoluteString;
    }
    
    ZOUrlSessionDownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:urlString];
    unit.tempFilePath = location.path;
    if (unit) {
        NSError *error;
        NSString* destinationPath = [unit.destinationDirectoryPath stringByAppendingPathComponent:[urlString lastPathComponent]];
        NSURL *dstUrl = [FileHelper urlForItemAtPath:destinationPath];
        [FileHelper createDirectoriesForFileAtPath:destinationPath];
        [FileHelper copyItemAtPath:location toPath:dstUrl error:&error];
        
        completionBlock(destinationPath, unit);
        
        [FileHelper removeItemAtPath:unit.tempFilePath];
        
        [weakself.currentDownloadUnits removeObjectForKey:unit.requestUrl];
        
        [unit.task cancel];
        unit.task = nil;
        unit.downloadState = ZODownloadStateDone;
    } else {
        [downloadTask cancel];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    if (!error) return;
    
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    NSString *urlString = task.currentRequest.URL.absoluteString;
    if (!urlString) {
        urlString = task.originalRequest.URL.absoluteString;
    }
    
    ZOUrlSessionDownloadUnit* unit = [weakself.currentDownloadUnits objectForKey:urlString];
    
    switch (error.code) {
        case ZODownloadErrorCancelled:
        {
            
            NSInteger errorReasonNum = [[error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] integerValue];
            if([error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] &&
               (errorReasonNum == NSURLErrorCancelledReasonUserForceQuitApplication ||
                errorReasonNum == NSURLErrorCancelledReasonBackgroundUpdatesDisabled))
            {
                // User force quit application. Invalid all previous session
                
            } else {
                // Try resume data
                NSData* resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                if (resumeData) {
                    unit.task = [[weakself _getUrlSessionBasedOnUnit:unit] downloadTaskWithResumeData:resumeData];
                    [task resume];
                } else {
                    [task cancel];
                }
                
            }
            break;
        }
        case ZODownloadErrorNoInternet:
        {
            // Add retry count
            // Dispatch retry after an interval
            
//            weakself.currentDownloadingCount--;
            unit.downloadState = ZODownloadStateError;
            if (![weakself _retryWithUrl:urlString]){
                unit.errorBlock(error);
                unit.downloadError = error;
                for (ZODownloadErrorBlock errorBlock in unit.otherErrorBlocks) {
                    errorBlock(error);
                }
            }
            
            break;
        }
            
        case ZODownloadErrorNoTimeoutRequest:
        {
            // Add retry count
            // Dispatch retry after an interval
//            weakself.currentDownloadingCount--;
            unit.downloadState = ZODownloadStateError;
            if (![weakself _retryWithUrl:urlString]){
                unit.errorBlock(error);
                unit.downloadError = error;
                for (ZODownloadErrorBlock errorBlock in unit.otherErrorBlocks) {
                    errorBlock(error);
                }
            }
            break;
        }
        case ZODownloadErrorNetworkConnectionList:{
//            weakself.currentDownloadingCount--;
            unit.downloadState = ZODownloadStateError;
            if (![weakself _retryWithUrl:urlString]){
                unit.errorBlock(error);
                unit.downloadError = error;
                for (ZODownloadErrorBlock errorBlock in unit.otherErrorBlocks) {
                    errorBlock(error);
                }
            }
            break;
        }
        default: {
            unit.downloadState = ZODownloadStateError;
            unit.errorBlock(error);
            unit.downloadError = error;
            for (ZODownloadErrorBlock errorBlock in unit.otherErrorBlocks) {
                errorBlock(error);
            }
            break;
        }
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate*) UIApplication.sharedApplication.delegate;
        appDelegate.backgroundSessionCompleteHandler();
        appDelegate.backgroundSessionCompleteHandler = nil;
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString *urlString = downloadTask.originalRequest.URL.absoluteString;
    if (!urlString) {
        urlString = downloadTask.currentRequest.URL.absoluteString;
    }
    
    ZOUrlSessionDownloadUnit* unit = [self.currentDownloadUnits objectForKey:urlString];
    
    CGFloat progress = (CGFloat)totalBytesWritten/ (CGFloat)totalBytesExpectedToWrite;
    NSUInteger remainingTime = [self remainingTimeForDownload:unit bytesTransferred:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    NSUInteger speed = bytesWritten/1024;
    if (unit.progressBlock) {
        unit.progressBlock(progress, speed, remainingTime);
    }
    if (unit.progressBlock) {
        unit.progressBlock(progress, speed, remainingTime);
    }
}

@end
