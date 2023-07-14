//
//  CacheService.m
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//

#import "CacheService.h"
#import "FileHelper.h"

@interface CacheService ()
@property (strong, nonatomic) NSMutableDictionary* ramImageCaches;
@property (strong, nonatomic) NSMutableDictionary* diskImageCaches;
@property (nonatomic) dispatch_queue_t cacheQueue;
@end

@implementation CacheService

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.ramImageCaches = [@{} mutableCopy];
        self.diskImageCaches = [@{} mutableCopy];
        self.cacheQueue = dispatch_queue_create("com.cacheservice.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [self loadDiskCache];
    return self;
}

-(void) loadDiskCache {
    __weak CacheService *weakself = self;
    dispatch_async(_cacheQueue, ^{
        NSString* cacheDirectory = [FileHelper pathForCachesDirectory];
        
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory
                                                                            error:NULL];
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *fileName = (NSString *)obj;
            NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
            [weakself.diskImageCaches setObject:filePath forKey:fileName];
        }];
    });
}

- (void)didReceiveMemoryWarning:(NSNotification *)note {
    [self freeAllCache];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)freeAllCache {
    __weak CacheService *weakself = self;
    dispatch_async(_cacheQueue, ^{
        NSArray* allKeys = [weakself.ramImageCaches allKeys];
        
        for (int i = 0; i < allKeys.count; i++) {
            [weakself deleteImageByKey:allKeys[i]];
        };
    });
}

- (void)freeHalfCache {
    __weak CacheService *weakself = self;
    dispatch_async(_cacheQueue, ^{
        NSArray* allKeys = [weakself.ramImageCaches allKeys];
        
        for (int i = 0; i < allKeys.count/2; i++) {
            [weakself deleteImageByKey:allKeys[i]];
        };
    });
}

-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key {
    if (image != nil && key != nil){
        UIImage* cachedImage = [image copy];
        [_ramImageCaches setObject:cachedImage forKey:key];
        
        __weak CacheService *weakself = self;
        dispatch_async(_cacheQueue, ^{
            NSString* cacheDirectory = [FileHelper pathForCachesDirectory];
            NSData *imageData = UIImageJPEGRepresentation(cachedImage, 0.85);
            
            NSString *filePath = [cacheDirectory stringByAppendingPathComponent:key];
            BOOL isWrited = [imageData writeToFile:filePath atomically:YES];
            if (isWrited) {
                [weakself.diskImageCaches setObject:filePath forKey:key];
            } else {
                //TODO: Handle write disk cache failed
            }
        });
    }
}

-(UIImage*)getImageByKey:(NSString*)key {
    // Access Ram cache
    UIImage *result = _ramImageCaches[key];
    
    // Access Disk cache
    if (result == nil && _diskImageCaches[key] != nil) {
        result = [FileHelper readFileAtPathAsImage:_diskImageCaches[key]];
        
        // Re-assign ram-cache
        _ramImageCaches[key] = result;
    }
    
    return result;
}
-(void)deleteImageByKey:(NSString*)key {
    if (!key)
        return;
    
    __weak CacheService *weakself = self;
    dispatch_async(_cacheQueue, ^{
        [weakself.ramImageCaches removeObjectForKey: key];
        NSString* cacheDirectory = [FileHelper pathForCachesDirectory];
        
         NSString *filePath = [cacheDirectory stringByAppendingPathComponent:key];
        BOOL isDeleted = [FileHelper removeItemAtPath:filePath];
        if (isDeleted) {
            [weakself.diskImageCaches removeObjectForKey: key];
        } else {
            //TODO: - Retry delete
            //TODO: - Add to "Tobedeleted" queue for future delete.
        }
        
    });
}

@end
