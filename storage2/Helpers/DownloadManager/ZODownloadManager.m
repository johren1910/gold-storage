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
@property (nonatomic, strong) NSMutableDictionary<NSString*, ZODOwnloadUnit*> *currentDownloadUnits;
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
    }
    return self;
}

- (void)startDownloadWithUnit:(id<ZODownloadUnitType>)unit {
    if (unit.downloadItem.requestUrl.length == 0)
        return;
    __weak ZODownloadManager* weakself = self;
    
    if(!unit.downloadRepository){
        ZOUrlSessionDownloadRepository* repository = [[ZOUrlSessionDownloadRepository alloc] init];
        [unit setRepository:repository];
    }
    
    dispatch_async(_serialDispatchQueue, ^{
        ZODOwnloadUnit *existUnit = [weakself.currentDownloadUnits objectForKey:unit.downloadItem.requestUrl];
        if (existUnit &&  (existUnit.downloadItem.downloadState == ZODownloadStateDownloading || existUnit.downloadItem.downloadState == ZODownloadStatePending)) {
            [existUnit.downloadItem.otherCompletionBlocks addObject:unit.downloadItem.completionBlock];
            [existUnit.downloadItem.otherErrorBlocks addObject:unit.downloadItem.errorBlock];
            
        } else {
            NSLog(@"LOG 2");
            unit.downloadItem.currentRetryAttempt = 0;
            unit.downloadItem.maxRetryCount = MAX_RETRY;
            unit.downloadItem.downloadState = ZODownloadStatePending;
            unit.downloadItem.otherCompletionBlocks = [[NSMutableArray alloc] init];
            unit.downloadItem.otherErrorBlocks = [[NSMutableArray alloc]init];
            unit.downloadItem.startDate = [NSDate date];
            
            // Check if already exist at destinationPath
            if (unit.downloadItem.destinationDirectoryPath) {
                NSString* destinationPath = [unit.downloadItem.destinationDirectoryPath stringByAppendingPathComponent:[unit.downloadItem.requestUrl lastPathComponent]];
                if ([FileHelper existsItemAtPath:destinationPath]) {
                    // File already downloaded
                    unit.downloadItem.completionBlock(destinationPath);
                    for (ZODownloadCompletionBlock block in unit.downloadItem.otherCompletionBlocks) {
                        block(destinationPath);
                    }
                    return;
                }
            } else {
               
                NSString* fileName = [unit.downloadItem.requestUrl lastPathComponent];
                NSString* filePath = [weakself _checkExistAtDefaultDirectory:fileName];
                if (filePath) {
                    unit.downloadItem.completionBlock(filePath);
                    for (ZODownloadCompletionBlock block in unit.downloadItem.otherCompletionBlocks) {
                        block(filePath);
                    }
                    return;
                }
            }
            
            [weakself _addPendingUnit:unit];
            [weakself.currentDownloadUnits setObject:unit forKey:unit.downloadItem.requestUrl];
            [weakself checkDownloadPipeline];
        }
    });
}


-(NSString*)_checkExistAtDefaultDirectory:(NSString*)fileName {
    
    NSString* pictureFolder = [FileHelper getDefaultDirectoryByFileType:Picture];
    NSString* videoFolder = [FileHelper getDefaultDirectoryByFileType:Video];
    pictureFolder = [FileHelper absolutePath:pictureFolder];
    
    videoFolder = [FileHelper absolutePath:videoFolder];
    
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
        ZODOwnloadUnit* unit = [weakself.currentDownloadUnits objectForKey:url];
        if (unit.downloadItem.downloadState == ZODownloadStateDownloading) {
            weakself.currentDownloadingCount--;
        }
        [unit pause];
        [weakself checkDownloadPipeline];
    });
}

- (void)suspendAllDownload{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        [weakself.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZODOwnloadUnit* value, BOOL* stop) {
            [value pause];
        }];
        weakself.currentDownloadingCount = 0;
    });
}

- (void)resumeDownloadOfUrl:(NSString *)url{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        ZODOwnloadUnit *unit = [weakself.currentDownloadUnits objectForKey:url];
        if (unit.downloadItem.downloadState != ZODownloadStateDone && unit.downloadItem.downloadState != ZODownloadStateDownloading ) {
            [unit resume];
            [weakself _addPendingUnit:unit];
            [weakself checkDownloadPipeline];
        }
    });
}

- (void)resumeAllDownload{
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        
        __weak ZODownloadManager* weakself = self;
        [weakself.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZODOwnloadUnit* value, BOOL* stop) {
            [value resume];
        }];
    });
}

- (void)cancelDownloadOfUrl:(NSString *)url {
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        ZODOwnloadUnit* unit = [weakself.currentDownloadUnits objectForKey:url];
        if (unit.downloadItem.downloadState == ZODownloadStateDownloading) {
            weakself.currentDownloadingCount--;
        }
        [unit cancle];
        
        [weakself.priorityQueue remove:unit];
        [weakself.currentDownloadUnits removeObjectForKey:url];

        [weakself checkDownloadPipeline];
        
    });
   
}

- (void)cancelAllDownload{
    
    __weak ZODownloadManager* weakself = self;
    dispatch_async(_serialDispatchQueue, ^{
        [weakself.currentDownloadUnits enumerateKeysAndObjectsUsingBlock:^(id key, ZODOwnloadUnit* value, BOOL* stop) {
            value.downloadItem.completionBlock = nil;
            value.downloadItem.otherCompletionBlocks = nil;
            value.downloadItem.errorBlock = nil;
            value.downloadItem.otherErrorBlocks = nil;
            if(value.downloadItem.tempFilePath){
                [FileHelper removeItemAtPath:value.downloadItem.tempFilePath];
            }
            [value cancle];
        }];
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
- (void)_removePendingUnit:(id<ZODownloadUnitType>)unit {
    [_priorityQueue remove:unit];
}

- (void)_addPendingUnit:(id<ZODownloadUnitType>)unit {
    [_priorityQueue enqueue:unit];
}

- (ZODOwnloadUnit *)_getNextDownloadUnit {
    return [_priorityQueue dequeue];
}

-(void)_prepare {
    _maxConcurrentDownloads = MAX_DOWNLOAD_CONCURRENT;
    _currentDownloadingCount = 0;
    _currentDownloadUnits = [NSMutableDictionary new];
    _priorityQueue = [[ZOPriorityQueue alloc] init];
    
    _serialDispatchQueue = dispatch_queue_create("com.ZODownloadManager.operationQueue", DISPATCH_QUEUE_SERIAL);
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
}

- (void)_startDownloadItem:(ZODOwnloadUnit *)unit {
    if (unit.downloadItem.requestUrl.length == 0) {
        return;
    }
    __weak ZODownloadManager* weakself = self;
    unit.downloadItem.downloadState = ZODownloadStateDownloading;
    NSLog(@"LOG 3");
    weakself.currentDownloadingCount++;
    __weak ZODOwnloadUnit *weakUnit = unit;
    [unit start:^(NSString* resultPath){
        dispatch_async(weakself.serialDispatchQueue, ^{
            if (!resultPath)
                return;
            unit.downloadRepository = nil;
            [weakself.currentDownloadUnits removeObjectForKey:unit.downloadItem.requestUrl];

            unit.downloadItem.downloadState = ZODownloadStateDone;
            
            unit.downloadItem.completionBlock(resultPath);
            for (ZODownloadCompletionBlock block in unit.downloadItem.otherCompletionBlocks) {
                block(resultPath);
            }
            
            unit.downloadRepository = nil;
            unit.downloadItem = nil;
            weakself.currentDownloadingCount--;
            [weakself checkDownloadPipeline];
        });
    } errorBlock:^(NSError* error) {
        dispatch_async(weakself.serialDispatchQueue, ^{
            if (unit) {
                unit.downloadItem.errorBlock(error);
                for (ZODownloadErrorBlock block in unit.downloadItem.otherErrorBlocks) {
                    block(error);
                }
                unit.downloadItem.downloadState = ZODownloadStateError;
                weakself.currentDownloadingCount--;
                [weakself checkDownloadPipeline];
            }
        });
        
        
    } progressBlock:weakUnit.downloadItem.progressBlock];
}
@end
