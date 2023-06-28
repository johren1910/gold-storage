//
//  ZODownloadManager.m
//  storage2
//
//  Created by LAP14885 on 25/06/2023.
//

#import "ZODownloadManager.h"
#import "FileHelper.h"
#import "HashHelper.h"
#import "ReachabilityHelper.h"

@interface ZODownloadManager () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSURLSession *defaultUrlSession;
@property (nonatomic, strong) NSURLSession *backgroundUrlSession;
@property (nonatomic, strong) NSMutableDictionary *currentDownloadUnits;
@property (nonatomic, strong) dispatch_queue_t downloadDispatchQueue;
@property (nonatomic, strong) dispatch_queue_t operationDispatchQueue;
@property (nonatomic, strong) NSMutableArray<ZODownloadUnit *> *pendingDownloadUnits;
@property (nonatomic) NSUInteger currentDownloadingCount;
@property (nonatomic, strong) ReachabilityHelper *reachabilityHelper;
@property (nonatomic, strong) NSMutableArray *currentPendingArray;
@end

@implementation ZODownloadManager

#pragma mark - Initialization

+ (instancetype)getSharedInstance {
    static ZODownloadManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}
-(instancetype)init {
    if (self == [super init]) {
        _lock = [[NSLock alloc] init];
        [self prepare];
        
    }
    return self;
}

- (NSURLSession*) getUrlSessionBasedOnUnit:(ZODownloadUnit*)unit {
    if (unit.isBackgroundSession) {
        return self.backgroundUrlSession;
    } else {
        return self.defaultUrlSession;
    }
}

- (NSURLSession *)backgroundUrlSession {
    if (!_backgroundUrlSession) {
        NSURLSessionConfiguration *backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.zodownloadmanager.backgroundsession"];
        backgroundConfig.discretionary = true;
        backgroundConfig.sessionSendsLaunchEvents = true;
        _backgroundUrlSession = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:self delegateQueue:nil];
    }
    
    return _backgroundUrlSession;
}

- (NSURLSession *)defaultUrlSession {
    if (!_defaultUrlSession) {
        NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultConfig.waitsForConnectivity = true;  // waits for connectitity, don't notify error immediately.
        defaultConfig.timeoutIntervalForRequest = MAX_DOWNLOAD_TIMEOUT;
        _defaultUrlSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:self delegateQueue:nil];
    }
    return _defaultUrlSession;
}

-(void)prepare {
    _maxConcurrentDownloads = MAX_DOWNLOAD_CONRRUENT;
    _currentDownloadingCount = 0;
    _currentDownloadUnits = [NSMutableDictionary new];
    _downloadDispatchQueue = dispatch_queue_create("com.ZODownloadManager.downloadQueue", DISPATCH_QUEUE_CONCURRENT);
    _operationDispatchQueue = dispatch_queue_create("com.ZODownloadManager.operationQueue", DISPATCH_QUEUE_SERIAL);
    
    _allowAutoRetry = FALSE;
    _retryTimeout = MAX_DOWNLOAD_TIMEOUT;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
    self.reachabilityHelper = [ReachabilityHelper reachabilityForLocalWiFi];
    [self.reachabilityHelper startNotifier];
}

#pragma mark - Session manager

-(NSMutableArray *)currentPendingArray {
    if (!_currentPendingArray) {
        _currentPendingArray = [NSMutableArray array];
    }
    return _currentPendingArray;
}

- (void)startDownloadWithUrl:(NSString *)downloadUrl destinationDirectory:(NSString *)dstDirectory
        isBackgroundDownload:(BOOL)isBackgroundDownload progressBlock:(ZODownloadProgressBlock)progressBlock
                  completionBlock:(ZODownloadCompletionBlock)completionBlock
                     errorBlock:(ZODownloadErrorBlock)errorBlock {
    if (downloadUrl.length == 0) { return;}
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_operationDispatchQueue, ^{
        [weakself.lock lock];
        ZODownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:downloadUrl];
        if (!unit) {
            unit = [[ZODownloadUnit alloc] init];
            unit.requestUrl = downloadUrl;
            unit.downloadState = ZODownloadStatePending;
            unit.progressBlock = progressBlock;
            unit.completionBlock = completionBlock;
            unit.errorBlock = errorBlock;
            unit.startDate = [NSDate date];
            unit.isBackgroundSession = isBackgroundDownload;
            [self.currentPendingArray addObject:unit];
            if (!dstDirectory) {
                unit.destinationDirectoryPath = [FileHelper pathForDocumentsDirectory];
            } else {
                unit.destinationDirectoryPath = dstDirectory;
            }
            
            // Check if already exist at destinationPath
            NSString* destinationPath = [unit.destinationDirectoryPath stringByAppendingPathComponent:[downloadUrl lastPathComponent]];
            if ([FileHelper existsItemAtPath:destinationPath]) {
                // File already downloaded
                dispatch_async(self.downloadDispatchQueue, ^{
                    completionBlock(destinationPath);
                });
                return;
            }
        }
        [weakself checkDownloadPipeline];
        [weakself.lock unlock];
    });
    
    
}

- (void)suspendDownloadOfUrl:(NSString *)url{
    if (url.length == 0) {
        return;
    }
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_operationDispatchQueue, ^{
        [weakself.lock lock];
        ZODownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:url];
        if (unit) {
            [unit.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                if (resumeData) {
                    unit.resumeData = resumeData;
                }
            }];
            unit.downloadState = ZODownloadStateSuspended;
        }
        weakself.currentDownloadingCount--;
        [weakself checkDownloadPipeline];
        [weakself.lock unlock];
    });
}

- (void)suspendAllDownload{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_operationDispatchQueue, ^{
        [weakself.lock lock];
        [weakself.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZODownloadUnit* value, BOOL* stop) {
            if (value.downloadState == ZODownloadStateDownloading || value.downloadState == ZODownloadStatePending || value.downloadState == ZODownloadStateError) {
                [value.task suspend];
                value.downloadState = ZODownloadStateSuspended;
            }
        }];
        weakself.currentDownloadingCount = 0;
        [weakself.lock unlock];
    });
}

- (void)resumeDownloadOfUrl:(NSString *)url{
    if (url.length == 0) {
        return;
    }
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_operationDispatchQueue, ^{
        
        [weakself.lock lock];
        ZODownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:url];
        if (unit) {
            unit.downloadState = ZODownloadStatePending;
        } else {
            // Create another item to start?
        }
        
        [weakself checkDownloadPipeline];
        [weakself.lock unlock];
    });
    
}

- (void)resumeAllDownload{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_operationDispatchQueue, ^{
        [weakself.lock lock];
        
        [weakself.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZODownloadUnit* value, BOOL* stop) {
            if (value.downloadState != ZODownloadStateError || value.downloadState != ZODownloadStateDone || value.downloadState != ZODownloadStateDownloading ) {
                value.downloadState = ZODownloadStatePending;
            }
        }];
        
        [weakself checkDownloadPipeline];
        [weakself.lock unlock];
    });
    
}

- (void)cancelDownloadOfUrl:(NSString *)url{
    if (url.length == 0) {
        return;
    }
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_operationDispatchQueue, ^{
        
        [weakself.lock lock];
        ZODownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:url];
        
        // TODO: - Remove TEMP downloading files.
        if (unit) {
            if (unit.downloadState == ZODownloadStateDone) {
                return;
            } else {
                [unit.task cancel];
                unit.task = nil;
            }
            [weakself.currentDownloadUnits removeObjectForKey:url];
        }
        weakself.currentDownloadingCount--;
        [weakself checkDownloadPipeline];
        [weakself.lock unlock];
    });
   
}

- (void)cancelAllDownload{
    
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_operationDispatchQueue, ^{
        [weakself.lock lock];
        
        [weakself.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZODownloadUnit* value, BOOL* stop) {
            [value.task cancel];
            value.task = nil;
            [FileHelper removeItemAtPath:value.tempFilePath];
            if (value.downloadState != ZODownloadStateError || value.downloadState != ZODownloadStateDone ) {
                value.downloadState = ZODownloadStatePending;
            }
        }];
        
        [FileHelper clearTemporaryDirectory];
        [weakself.currentDownloadUnits removeAllObjects];
        weakself.currentDownloadingCount = 0;
        
        [weakself.lock unlock];
    });
    
}

- (void)checkDownloadPipeline {
    
    if (self.isAllowNewDownload) {
        for (ZODownloadUnit *unit in _currentPendingArray) {
            if (unit.downloadState == ZODownloadStatePending) {
                
                if (self.maxConcurrentDownloads - self.currentDownloadingCount > 0) {
                    [self startDownloadItem:unit];
                } else {
                    break;
                }
            }
        }
    }
}

- (void)cancelTaskOfUnit:(ZODownloadUnit *)unit {
    
    if (unit.task) {
        [unit.task cancel];
        unit.task = nil;
    }
    unit.downloadError = nil;
}

- (void)startDownloadItem:(ZODownloadUnit *)unit {
    if (unit.requestUrl.length == 0) {
        return;
    }
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_operationDispatchQueue, ^{

        unit.downloadState = ZODownloadStateDownloading;
        [weakself cancelTaskOfUnit:unit];
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        // TODO: CORNER CASE: If client A request ZODownloadManager to down linkA at background thread. The session is 50% done, another client B request ZODownloadManager to download the same file at foreground thread. Should we create a new download or reuse the current session of background thread?
        
        if (unit.isBackgroundSession) {
            [[weakself getUrlSessionBasedOnUnit:unit] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
                [downloadTasks enumerateObjectsUsingBlock:^(id task, NSUInteger idx, BOOL *stop) {
                    NSURLSessionTask *sessionTask = (NSURLSessionTask*) task;
                    if ([unit.requestUrl isEqualToString:sessionTask.originalRequest.URL.absoluteString]) {
                        
                        if (sessionTask.state == NSURLSessionTaskStateCompleted
                            && sessionTask.error) {
                            // App terminated manully by user. All background session download cleared, create new download
                            [sessionTask cancel];
                        } else {
                            unit.task = (NSURLSessionDownloadTask*)sessionTask;
                            [weakself.currentDownloadUnits setObject:unit forKey:unit.requestUrl];
                            if (sessionTask.state == NSURLSessionTaskStateSuspended) {
                                [sessionTask resume];
                            }
                            weakself.currentDownloadingCount++;
                        }
                    }
                }];
                
                if (!unit.task) {
                    NSURLSessionDownloadTask *downloadTask = [weakself createDownloadTaskWithUnit:unit];
                    
                    unit.task = downloadTask;
                    [weakself.currentDownloadUnits setObject:unit forKey:unit.requestUrl];
                    [downloadTask resume];
                    weakself.currentDownloadingCount++;
                }
            }];
        } else {
            NSURLSessionDownloadTask *downloadTask = [weakself createDownloadTaskWithUnit:unit];
            
            unit.task = downloadTask;
            [weakself.currentDownloadUnits setObject:unit forKey:unit.requestUrl];
            [downloadTask resume];
            weakself.currentDownloadingCount++;
        }
    });
}

#pragma mark - Helpers

-  (NSString *)getTempFilePath:(NSString *)downloadUrl {
    
    if (downloadUrl.length <= 0) {
        return nil;
    }
    
    NSString *hashedUrl = [HashHelper hashStringMD5:downloadUrl];
    NSString *tempFileName = [hashedUrl stringByAppendingString:@".download"];
    
    NSString *tempFilePath = [FileHelper pathForTemporaryDirectoryWithPath:tempFileName];
    
    if (![FileHelper existsItemAtPath:tempFilePath]) {
        [FileHelper createFileAtPath:tempFilePath];
    }
    return tempFilePath;
}

- (BOOL) isAllowNewDownload {
    return (_currentDownloadingCount < self.maxConcurrentDownloads);
}

- (NSURLSessionDownloadTask *)createDownloadTaskWithUnit:(ZODownloadUnit *)unit {
    NSURL *url = [NSURL URLWithString:unit.requestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask;
    if (unit.resumeData) {
        downloadTask = [[self getUrlSessionBasedOnUnit:unit] downloadTaskWithResumeData:unit.resumeData];
    } else {
        downloadTask = [[self getUrlSessionBasedOnUnit:unit] downloadTaskWithRequest:request];
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

#pragma mark - NSURLSessionDelegate, NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    [self.lock lock];
    NSString *urlString = downloadTask.originalRequest.URL.absoluteString;
    if (!urlString) {
        urlString = downloadTask.currentRequest.URL.absoluteString;
    }
    
    ZODownloadUnit* unit = [self.currentDownloadUnits objectForKey:urlString];
    
    CGFloat progress = (CGFloat)totalBytesWritten/ (CGFloat)totalBytesExpectedToWrite;
    NSUInteger remainingTime = [self remainingTimeForDownload:unit bytesTransferred:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    NSUInteger speed = bytesWritten/1024;
    dispatch_async(dispatch_get_main_queue(), ^{
        unit.progressBlock(progress, speed, remainingTime);
    });
    
    [self.lock unlock];
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {

    NSString *urlString = downloadTask.currentRequest.URL.absoluteString;
    if (!urlString) {
        urlString = downloadTask.originalRequest.URL.absoluteString;
    }
    
    ZODownloadUnit *unit = [self.currentDownloadUnits objectForKey:urlString];
    unit.tempFilePath = location.path;
    _currentDownloadingCount--;
    if (unit) {
        NSError *error;
        NSString* destinationPath = [unit.destinationDirectoryPath stringByAppendingPathComponent:[urlString lastPathComponent]];
        NSURL *dstUrl = [FileHelper urlForItemAtPath:destinationPath];
        [FileHelper createDirectoriesForFileAtPath:destinationPath];
        [FileHelper copyItemAtPath:location toPath:dstUrl error:&error];
        
        ZODownloadCompletionBlock completion = unit.completionBlock;
        if (completion) {
            dispatch_async(self.downloadDispatchQueue, ^{
                completion(destinationPath);
            });
            [FileHelper removeItemAtPath:unit.tempFilePath];
        }
        
        [self.currentDownloadUnits removeObjectForKey:unit.requestUrl];
        
        [unit.task cancel];
        unit.task = nil;
    } else {
        [downloadTask cancel];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (!error) return;
    
    NSString *urlString = task.currentRequest.URL.absoluteString;
    if (!urlString) {
        urlString = task.originalRequest.URL.absoluteString;
    }
    
    ZODownloadUnit* unit = [self.currentDownloadUnits objectForKey:urlString];
    
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
                    unit.task = [[self getUrlSessionBasedOnUnit:unit] downloadTaskWithResumeData:resumeData];
                    [task resume];
                }
            break;
        }
        case ZODownloadErrorNoInternet:
        {
            // Add retry count
            // Dispatch retry after an interval
            _currentDownloadingCount--;
            break;
        }
 
        case ZODownloadErrorNoTimeoutRequest:
        {
            // Add retry count
            // Dispatch retry after an interval
            _currentDownloadingCount--;
            break;
        }
        default: {
            _currentDownloadingCount--;
            unit.errorBlock(error);
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

#pragma mark - Reachability

- (void)networkChanged:(NSNotification *)note {
    ReachabilityHelper* reachability = [note object];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus) {
        case ReachableViaWiFi:
        case ReachableViaWWAN:
        {
            if (_allowAutoRetry) {
                //TODO: Auto Retry
//                [self resumeAllDownload];
            }
        }
            
        default:
            break;
    }
}
@end
