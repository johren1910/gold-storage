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

@property (nonatomic) NSURLSession *defaultUrlSession;
@property (nonatomic) NSURLSession *backgroundUrlSession;
@property (nonatomic) NSURLSessionDownloadTask* _downloadTask;
@property (nonatomic) id<ZODownloadItemType> _downloadItem;
@property (nonatomic) NSURLSession *_currentSession;

@end

@implementation ZOUrlSessionDownloadRepository

- (instancetype)init {
    if (self == [super init]) {
    }
    return self;
}

- (void)cancle {
    [self._downloadTask cancel];
    self._downloadTask = nil;
}

- (void)resume {
    if(self._downloadTask && self._downloadTask.state != NSURLSessionTaskStateCompleted) {
        [self._downloadTask resume];
    }
}

- (void)startDownloadWithItem:(id<ZODownloadItemType>)item {
    
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    weakself._downloadItem = item;
    weakself._currentSession = [weakself _getUrlSessionBasedOnItem:item];
    if (item.isBackgroundSession) {
        [weakself._currentSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            [weakself handleBackgroundSessionDownload:downloadTasks];
            
            if (!weakself._downloadTask) {
                NSURLSessionDownloadTask *downloadTask = [weakself _createDownloadTaskWithItem:weakself._downloadItem];
                
                weakself._downloadTask = downloadTask;
            }
            [weakself._downloadTask resume];
        }];
        
    } else {
        NSURLSessionDownloadTask *downloadTask = [weakself _createDownloadTaskWithItem:item];
        weakself._downloadTask = downloadTask;
        [weakself._downloadTask resume];
    }
}

-(void)handleBackgroundSessionDownload:(NSArray*)downloadTasks {
    
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    [downloadTasks enumerateObjectsUsingBlock:^(id task, NSUInteger idx, BOOL *stop) {
        NSURLSessionTask *sessionTask = (NSURLSessionTask*) task;
        if ([weakself._downloadItem.requestUrl isEqualToString:sessionTask.originalRequest.URL.absoluteString]) {
            
            if (sessionTask.state == NSURLSessionTaskStateCompleted
                && sessionTask.error) {
                // App terminated manully by user. All background session download cleared, create new download
                [sessionTask cancel];
            } else {
                weakself._downloadTask = (NSURLSessionDownloadTask*)sessionTask;
              
                if (sessionTask.state == NSURLSessionTaskStateSuspended) {
                    [sessionTask resume];
                }
            }
        }
    }];
}

-(void)pause {
    
    __weak ZOUrlSessionDownloadRepository* weakself = self;
    if (weakself._downloadTask) {
        [weakself._downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if (resumeData) {
                weakself._downloadItem.resumeData = resumeData;
            }
        }];
    }
}

@synthesize errorBlock;
@synthesize completionBlock;

#pragma mark - Private helpers

- (NSURLSession*) _getUrlSessionBasedOnItem:(id<ZODownloadItemType>)item {
    if (item.isBackgroundSession) {
        return [self _getBackgroundUrlSession:item.requestUrl];
    } else {
        return self._getDefaultUrlSession;
    }
}

- (NSURLSession *)_getBackgroundUrlSession:(NSString*)uniqueIdentifier {
    if (!_backgroundUrlSession) {
        
        NSString* identifier = [[NSString alloc] initWithFormat:@"com.zodownloadmanager.backgroundsession.%@", uniqueIdentifier];
        NSURLSessionConfiguration *backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
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
        defaultConfig.timeoutIntervalForRequest = 30;
        _defaultUrlSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:self delegateQueue:nil];
    }
    return _defaultUrlSession;
}

- (NSURLSessionDownloadTask *)_createDownloadTaskWithItem:(id<ZODownloadItemType>)item {
    NSURL *url = [NSURL URLWithString:item.requestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask;
    if (item.resumeData) {
        downloadTask = [self._currentSession downloadTaskWithResumeData:item.resumeData];
    } else {
        downloadTask = [self._currentSession downloadTaskWithRequest:request];
    }
    return downloadTask;
}

- (NSUInteger)remainingTimeForDownload:(int64_t)bytesTransferred
             totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self._downloadItem.startDate];
    CGFloat speed = (CGFloat)bytesTransferred / (CGFloat)timeInterval;
    CGFloat remainingBytes = totalBytesExpectedToWrite - bytesTransferred;
    CGFloat remainingTime = remainingBytes / speed;
    
    return (NSUInteger)remainingTime;
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
    NSString *resultPath = nil;
    NSError *error;
    if (weakself._downloadItem.destinationDirectoryPath) {
        NSString* destinationPath = [weakself._downloadItem.destinationDirectoryPath stringByAppendingPathComponent:[urlString lastPathComponent]];
        NSURL *dstUrl = [FileHelper urlForItemAtPath:destinationPath];
        [FileHelper createDirectoriesForFileAtPath:destinationPath];
        [FileHelper copyItemAtPath:location toPath:dstUrl error:&error];
        [FileHelper removeItemAtPath:location.path];
        resultPath = destinationPath;
    } else {
        NSString* fileName = [urlString lastPathComponent];
        NSString* tempFolder = [location.path stringByDeletingLastPathComponent];
        NSString* newFilePath = [tempFolder stringByAppendingPathComponent:fileName];
        NSURL *dstUrl = [FileHelper urlForItemAtPath:newFilePath];
        
        [FileHelper copyItemAtPath:location toPath:dstUrl error:&error];
        [FileHelper removeItemAtPath:location.path];
        resultPath = newFilePath;
    }
    
    [weakself._currentSession finishTasksAndInvalidate];
    [weakself.defaultUrlSession finishTasksAndInvalidate];
    [weakself.backgroundUrlSession finishTasksAndInvalidate];
    weakself.defaultUrlSession = nil;
    weakself.backgroundUrlSession = nil;
    weakself._currentSession = nil;
    weakself._downloadTask = nil;
    completionBlock(resultPath);
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
                    
                   weakself._downloadTask = [weakself._currentSession downloadTaskWithResumeData:resumeData];
                    [weakself._downloadTask resume];
                } else {
                    [weakself._downloadTask cancel];
                }
                
            }
            break;
        }
        case ZODownloadErrorNoInternet:
        {
            // Add retry count
            // Dispatch retry after an interval
            
            if (![weakself _retryWithUrl:urlString]){
                errorBlock(error);
            }
            
            break;
        }
            
        case ZODownloadErrorNoTimeoutRequest:
        {
            // Add retry count
            // Dispatch retry after an interval
            if (![weakself _retryWithUrl:urlString]){
                errorBlock(error);
            }
            break;
        }
        case ZODownloadErrorNetworkConnectionList:{
            if (![weakself _retryWithUrl:urlString]){
                errorBlock(error);
            }
            break;
        }
        default: {
            errorBlock(error);
            break;
        }
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate*) UIApplication.sharedApplication.delegate;
        if(appDelegate.backgroundSessionCompleteHandler)
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
    
    CGFloat progress = (CGFloat)totalBytesWritten/ (CGFloat)totalBytesExpectedToWrite;
    NSUInteger remainingTime = [self remainingTimeForDownload:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    NSUInteger speed = bytesWritten/1024;
    if (self.progressBlock) {
        self.progressBlock(progress, speed, remainingTime);
    }
}

@synthesize progressBlock;

@end
