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

@end

@implementation CacheService

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.ramImageCaches = [@{} mutableCopy];
        self.diskImageCaches = [@{} mutableCopy];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [self loadDiskCache];
    return self;
}

-(void) loadDiskCache {
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cachemanager.load.diskcache", DISPATCH_QUEUE_CONCURRENT);
    
    __weak CacheService *weakself = self;
    dispatch_async(myQueue, ^{
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
    
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cachemanager.freeram", DISPATCH_QUEUE_CONCURRENT);
    
    __weak CacheService *weakself = self;
    dispatch_async(myQueue, ^{
        NSArray* allKeys = [weakself.ramImageCaches allKeys];
        
        for (int i = 0; i < allKeys.count; i++) {
            [weakself.ramImageCaches removeObjectForKey:allKeys[i]];
        };
    });
}

- (void)freeHalfCache {
    
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cachemanager.freeram", DISPATCH_QUEUE_CONCURRENT);
    
    __weak CacheService *weakself = self;
    dispatch_async(myQueue, ^{
        NSArray* allKeys = [weakself.ramImageCaches allKeys];
        
        for (int i = 0; i < allKeys.count/2; i++) {
            [weakself.ramImageCaches removeObjectForKey:allKeys[i]];
        };
    });
}

-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key {
    if (image != nil && key != nil){
        [_ramImageCaches setObject:image forKey:key];
    }
    
    // Disk Cache
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cachemanager.write.diskcache", DISPATCH_QUEUE_CONCURRENT);
    
    __weak CacheService *weakself = self;
    dispatch_async(myQueue, ^{
        NSString* cacheDirectory = [FileHelper pathForCachesDirectory];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.85);
        
        NSString *filePath = [cacheDirectory stringByAppendingFormat:@"/%@", key];
        BOOL isWrited = [imageData writeToFile:filePath atomically:YES];
        if (isWrited) {
            [weakself.diskImageCaches setObject:filePath forKey:key];
        } else {
            //TODO: Handle write disk cache failed
        }
    });
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
    [_ramImageCaches removeObjectForKey: key];
    
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cachemanager.deletekey", DISPATCH_QUEUE_CONCURRENT);
    __weak CacheService *weakself = self;
    dispatch_async(myQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* cacheDirectory = [FileHelper pathForCachesDirectory];
        NSString *filePath = [cacheDirectory stringByAppendingFormat:@"/%@", key];
        NSError *error;
        BOOL isDeleted = [fileManager removeItemAtPath:filePath error:&error];
        if (isDeleted) {
            [weakself.diskImageCaches removeObjectForKey: key];
        } else {
            //TODO: - Retry delete
            //TODO: - Add to "Tobedeleted" queue for future delete.
        }
        
    });
}

@end
