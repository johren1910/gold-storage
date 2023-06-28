//
//  AppService.m
//  storage2
//
//  Created by LAP14885 on 28/06/2023.
//

#import <Foundation/Foundation.h>
#import "AppService.h"

@interface AppService ()
@property (nonatomic) NSArray* services;
@property (strong, nonatomic) id<CacheServiceType> cacheService;
@property (strong, nonatomic) id<ZODownloadManagerType> downloadManager;
@property (strong, nonatomic) id<StorageManagerType> storageManager;
@property (strong, nonatomic) id<DatabaseManagerType> databaseManager;
@end

@implementation AppService

- (instancetype)init {
    if (self == [super init]) {
        _cacheService = [[CacheService alloc] init];
        _databaseManager = [DatabaseManager getSharedInstance];
        _storageManager = [[StorageManager alloc] initWithCacheService:_cacheService andDatabaseManager:_databaseManager];
        _downloadManager = [ZODownloadManager getSharedInstance];
        _services = @[_cacheService, _databaseManager, _storageManager, _downloadManager];
    }
    return self;
}

-(id) getService:(id)class {
    for (id service in _services) {
        if ([service isKindOfClass:class]) {
            return service;
        }
    }
    return nil;
}

// TODO: -FIX register/resolve
//- (void) registerServices {
//    for (id<FactoryResolvable> service in _services) {
//        [service inject];
//    }
//}
//- (id) getService:(Class) service {
//    if ([_services containsObject:service]) {
//        return [(id<FactoryResolvable>)service resolve];
//    }
//    return nil;
//}

@end
