//
//  CacheManager.m
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//

#import "CacheManager.h"

@interface CacheManager ()
@property (strong, nonatomic) NSMutableDictionary* ramImageCaches;
@property (strong, nonatomic) NSMutableDictionary* diskImageCaches;

@end

@implementation CacheManager

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.ramImageCaches = [@{} mutableCopy];
        self.diskImageCaches = [@{} mutableCopy];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    return self;
}

- (void)didReceiveMemoryWarning:(NSNotification *)note {
    [self freeAllCache];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)freeAllCache {
    
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cachemanager.freeram", DISPATCH_QUEUE_CONCURRENT);
    
    __weak CacheManager *weakself = self;
    dispatch_async(myQueue, ^{
        NSArray* allKeys = [weakself.ramImageCaches allKeys];
        
        for (int i = 0; i < allKeys.count; i++) {
            [weakself.ramImageCaches removeObjectForKey:allKeys[i]];
        };
    });
}

- (void)freeHalfCache {
    
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cachemanager.freeram", DISPATCH_QUEUE_CONCURRENT);
    
    __weak CacheManager *weakself = self;
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
    
    // Check suitable for disk-cache
}

-(UIImage*)getImageByKey:(NSString*)key {
    return _ramImageCaches[key];
}
-(void)deleteImageByKey:(NSString*)key {
    [_ramImageCaches removeObjectForKey: key];
}

@end
