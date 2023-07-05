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
#import "ZOPriorityQueue.h"
#import "ZOUrlSessionDownloadRepostiory.h"

@interface ZODownloadManager ()

@property (nonatomic, strong) dispatch_queue_t serialDispatchQueue;

@property (nonatomic) NSUInteger currentDownloadingCount;

@property (nonatomic, strong) ReachabilityHelper *reachabilityHelper;

@property (nonatomic, strong) ZOPriorityQueue* priorityQueue;
@property (nonatomic, strong) NSMutableDictionary *currentDownloadUnits;
@property (nonatomic) id<ZODownloadRepositoryInterface> downloadRepository;
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
        [self _prepare];
        [self _handlerCompletion];
    }
    return self;
}

- (void)startDownloadWithUnit:(ZODownloadUnit*)unit {
    if (unit.requestUrl.length == 0)
        return;
    __weak ZODownloadManager* weakself = self;
    
    dispatch_async(_serialDispatchQueue, ^{
        ZODownloadUnit *existUnit = [weakself.currentDownloadUnits objectForKey:unit.requestUrl];
        if (existUnit && existUnit.downloadState != ZODownloadStateDownloading && existUnit.downloadState != ZODownloadStateDone) {
            [existUnit.otherCompletionBlocks addObject:unit.completionBlock];
            [existUnit.otherErrorBlocks addObject:unit.errorBlock];
            
        } else {
            NSLog(@"LOG 2");
            unit.currentRetryAttempt = 0;
            unit.maxRetryCount = MAX_RETRY;
            unit.downloadState = ZODownloadStatePending;
            unit.otherCompletionBlocks = [[NSMutableArray alloc] init];
            unit.otherErrorBlocks = [[NSMutableArray alloc]init];
            unit.startDate = [NSDate date];
            
            // Check if already exist at destinationPath
            if (unit.destinationDirectoryPath) {
                NSString* destinationPath = [unit.destinationDirectoryPath stringByAppendingPathComponent:[unit.requestUrl lastPathComponent]];
                if ([FileHelper existsItemAtPath:destinationPath]) {
                    // File already downloaded
                    unit.completionBlock(destinationPath);
                    for (ZODownloadCompletionBlock block in unit.otherCompletionBlocks) {
                        block(destinationPath);
                    }
                    return;
                }
            } else {
               
                NSString* fileName = [unit.requestUrl lastPathComponent];
                NSString* filePath = [weakself _checkExistAtDefaultDirectory:fileName];
                if (filePath) {
                    unit.completionBlock(filePath);
                    for (ZODownloadCompletionBlock block in unit.otherCompletionBlocks) {
                        block(filePath);
                    }
                    return;
                }
            }
            
            [weakself _addPendingUnit:unit];
            [weakself.currentDownloadUnits setObject:unit forKey:unit.requestUrl];
            [weakself checkDownloadPipeline];
        }
    });
}


-(NSString*)_checkExistAtDefaultDirectory:(NSString*)fileName {
    
    NSString* pictureFolder = [FileHelper getDefaultDirectoryByFileType:Picture];
    NSString* videoFolder = [FileHelper getDefaultDirectoryByFileType:Video];
    pictureFolder = [FileHelper pathForApplicationSupportDirectoryWithPath:pictureFolder];
    
    videoFolder = [FileHelper pathForApplicationSupportDirectoryWithPath:videoFolder];
    
    NSString* filePath = [pictureFolder stringByAppendingPathComponent:fileName];
    if ([FileHelper existsItemAtPath:filePath]) {
        return filePath;
    }
    
    filePath = [videoFolder stringByAppendingPathComponent:fileName];
    if ([FileHelper existsItemAtPath:filePath]) {
        return filePath;
    }
    
    return nil;
}

- (void)suspendDownloadOfUrl:(NSString *)url{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        [weakself.downloadRepository suspendDownloadOfUrl:url];
        weakself.currentDownloadingCount--;
        [weakself checkDownloadPipeline];
    });
}

- (void)suspendAllDownload{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        [weakself.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZODownloadUnit* value, BOOL* stop) {
            [weakself suspendDownloadOfUrl:value.requestUrl];
        }];
        weakself.currentDownloadingCount = 0;
    });
}

- (void)resumeDownloadOfUrl:(NSString *)url{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{

        [weakself.downloadRepository resumeDownloadOfUrl:url];
        ZODownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:url];
        [weakself _addPendingUnit:unit];
        [weakself checkDownloadPipeline];
    });
    
}

- (void)resumeAllDownload{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        [weakself.downloadRepository resumeAllDownload];
        [weakself checkDownloadPipeline];
    });
}

- (void)cancelDownloadOfUrl:(NSString *)url {
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        
        [weakself.downloadRepository cancelDownloadOfUrl:url];
        ZODownloadUnit* unit = [weakself.currentDownloadUnits objectForKey:url];
        [weakself.priorityQueue remove:unit];
        [weakself.currentDownloadUnits removeObjectForKey:url];
        // TODO: CHECK cancel downloading -> --count
//        ZODownloadUnit *unit = [weakself.currentDownloadUnits objectForKey:url];
        [weakself checkDownloadPipeline];
        
    });
   
}

- (void)cancelAllDownload{
    
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        [weakself.downloadRepository cancelAllDownload];
        [FileHelper clearTemporaryDirectory];
        [weakself.currentDownloadUnits removeAllObjects];
        weakself.currentDownloadingCount = 0;
    });
    
}

- (void)checkDownloadPipeline {
    
    if (self._isAllowNewDownload) {
        [self _startDownloadItem:[self _getNextDownloadUnit]];
    }
}

#pragma mark - Reachability

- (void)_networkChanged:(NSNotification *)note {
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        ReachabilityHelper* reachability = [note object];
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        switch (netStatus) {
            case ReachableViaWiFi:
            case ReachableViaWWAN:
            {
                if (weakself.allowAutoRetry) {
                    //TODO: Auto Retry
                    //[self resumeAllDownload];
                }
            }
                
            default:
                break;
        }
    });
    
}

#pragma mark - Private methods
-(void)setDownloadRepository:(id<ZODownloadRepositoryInterface>)repository {
    _downloadRepository = repository;
}

- (void)_removePendingUnit:(ZODownloadUnit *)unit {
    [_priorityQueue remove:unit];
}

- (void)_addPendingUnit:(ZODownloadUnit *)unit {
    [_priorityQueue enqueue:unit];
}

- (ZODownloadUnit *)_getNextDownloadUnit {
    return [_priorityQueue dequeue];
}

-(void)_handlerCompletion {
    __weak ZODownloadManager* weakself = self;
    self.downloadRepository.completionBlock = ^(NSString *filePath, ZODownloadUnit* unit) {
        dispatch_async(weakself.serialDispatchQueue, ^{
            unit.completionBlock(filePath);
            for (ZODownloadCompletionBlock block in unit.otherCompletionBlocks) {
                block(filePath);
            }
            ZODownloadUnit *manageUnit = [weakself.currentDownloadUnits objectForKey:unit.requestUrl];
            manageUnit.downloadState = ZODownloadStateDone;
            weakself.currentDownloadingCount--;
            [weakself checkDownloadPipeline];
        });
        
    };
    
    self.downloadRepository.errorBlock = ^(NSError* error, ZODownloadUnit* unit) {
        dispatch_async(weakself.serialDispatchQueue, ^{
            if (unit) {
                unit.errorBlock(error);
                for (ZODownloadErrorBlock block in unit.otherErrorBlocks) {
                    block(error);
                }
                
                ZODownloadUnit *manageUnit = [weakself.currentDownloadUnits objectForKey:unit.requestUrl];
                manageUnit.downloadState = ZODownloadStateError;
                weakself.currentDownloadingCount--;
                [weakself checkDownloadPipeline];
            }
        });
    };
}

-(void)_prepare {
    _maxConcurrentDownloads = MAX_DOWNLOAD_CONCURRENT;
    _currentDownloadingCount = 0;
    _currentDownloadUnits = [NSMutableDictionary new];
    _priorityQueue = [[ZOPriorityQueue alloc] init];
    
    _serialDispatchQueue = dispatch_queue_create("com.ZODownloadManager.operationQueue", DISPATCH_QUEUE_SERIAL);
    _downloadRepository = [[ZOUrlSessionDownloadRepository alloc] init];
    _allowAutoRetry = FALSE;
    _retryTimeout = MAX_DOWNLOAD_TIMEOUT;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_networkChanged:) name:kReachabilityChangedNotification object:nil];
    self.reachabilityHelper = [ReachabilityHelper reachabilityForLocalWiFi];
    [self.reachabilityHelper startNotifier];
}


- (BOOL) _isAllowNewDownload {
    return (self.currentDownloadingCount < self.maxConcurrentDownloads);
}

- (BOOL)_retryWithUrl:(NSString *)url {
    
    return false;
//    ZODownloadUnit *unit = [self.currentDownloadUnits objectForKey:url];
//
//    if (unit.currentRetryAttempt >= unit.maxRetryCount) {
//        unit.currentRetryAttempt = 0;
//        return FALSE;
//    }
//    unit.currentRetryAttempt++;
//    if (unit) {
//        [unit.task cancel];
//        unit.task = nil;
//
//        unit.priority = ZODownloadPriorityRetryImmediate;
//        [self addPendingUnit:unit];
//    }
//    return TRUE;
}

- (void)_startDownloadItem:(ZODownloadUnit *)unit {
    if (unit.requestUrl.length == 0) {
        return;
    }
    __weak ZODownloadManager* weakself = self;
    unit.downloadState = ZODownloadStateDownloading;
    NSLog(@"LOG 3");
    [self.downloadRepository startDownloadWithUnit:unit completionBlock:^(BOOL isDownloadStarted) {
        if(isDownloadStarted) {
            weakself.currentDownloadingCount++;
        }
    }];
}
@end
